// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import "./NFTLibrary.sol";
import "./interface/IController.sol";
import "./Collection.sol";


contract Controller is IController, Initializable, AccessControlUpgradeable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using NFTLibrary for address;

    using MerkleProof for bytes32[];


    address public eternalStorage;

    address public dynamicNFTCollectionAddress;

    uint256 public tokenId;

    Collection NFT;

    /* ========== EVENTS ========== */

    event Mint(uint256 _tokenId, address _minter, string uri, bytes32 _title, bytes32 _description, uint256 _price, uint256 rentPrice, uint256 rentDuration, uint256 videoDuration);
    event BuyNFT(uint256 _tokenId, address from, address to);
    event RentRequest(uint256 _tokenId, address mainRenter, address[] coOwners);
    event PayForRent(uint256 _tokenId, address renter);
    event RentFinishTime(uint256 _tokenId, uint256 start, uint256 duration);
    event RentStarted(uint256 _tokenId, address[] coOwners);
    event AuctionRequest(uint256 _tokenId, uint256 _stepPrice, uint256 _stepTime);
    event AuctionIteration(uint256 _tokenId, uint256 _newPrice);



    function initialize(address _eternalStorage, address _dynamicNFTCollectionAddress) public initializer {
        eternalStorage = _eternalStorage;
        dynamicNFTCollectionAddress = _dynamicNFTCollectionAddress;
        NFT = Collection(dynamicNFTCollectionAddress);

        tokenId = 0;

        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function mint(string memory uri, bytes32 _title, bytes32 _description, uint256 _price, uint256 rentPrice, uint256 rentDuration, uint256 videoDuration) external override returns (uint256){

        tokenId = tokenId + 1;

        NFT.mint(_msgSender(), tokenId);
        NFT.setTokenURI(tokenId, uri);
        eternalStorage.saveMediaInfo(tokenId, _title, _description, _price, rentPrice, rentDuration, videoDuration);

        emit Mint(tokenId, _msgSender(), uri, _title, _description, _price, rentPrice, rentDuration, videoDuration);

        return tokenId;
    }

    function auctionRequest(uint256 _tokenId, uint256 _stepPrice, uint256 _stepTime) external override {
        require(_msgSender() == NFT.ownerOf(_tokenId), "not an owner");
        eternalStorage.saveAuctionRequestInfo(_tokenId, _stepPrice, _stepTime);

        emit AuctionRequest(_tokenId, _stepPrice, _stepTime);

    }

    function iterAuction(uint256 _tokenId) external override {
        uint256 stepTime;
        uint256 stepPrice;
        uint256 lastStepTime;
        (stepTime, stepPrice, lastStepTime) = eternalStorage.getAuctionRequestInfo(_tokenId);

        require(lastStepTime + stepTime < block.timestamp, "not time");
        uint256 currentPrice = eternalStorage.getMediaPrice(_tokenId);
        require(
            currentPrice > stepPrice,
                "NFT price must be greater than zero"
        );
        uint256 newPrice = currentPrice - stepPrice;
        eternalStorage.saveMediaPrice(_tokenId, newPrice);
        eternalStorage.saveAuctionRequestInfo(_tokenId, stepPrice, stepTime);

        emit AuctionIteration(_tokenId, newPrice);
    }

    function buyNFT(uint256 _tokenId) external payable override {
        require(eternalStorage.mediaRentStatus(_tokenId) == false, "media rented now");

        address from = NFT.ownerOf(tokenId);
        address to = _msgSender();

        uint256 price = eternalStorage.getMediaPrice(_tokenId);

        require(
            msg.value >= price,
            "Not enough funds"
        );

        NFT.buy(from, to, _tokenId);

        _forwardFunds(payable(from));

        emit BuyNFT(_tokenId, from, to);
    }

    function rentRequest(uint256 _tokenId, bytes32 coOwners, address[] memory coOwnersList) external payable {
        eternalStorage.handleRentRequest(_tokenId, _msgSender(), coOwners, coOwnersList.length, coOwnersList, msg.value);
        _forwardFunds(payable(NFT.ownerOf(_tokenId)));
        emit RentRequest(_tokenId, _msgSender(), coOwnersList);
        if (eternalStorage.hasEveryOnePaid(_tokenId, _msgSender())) {
            eternalStorage.updateRentStatus(_tokenId);
            emit RentFinishTime(_tokenId, uint256(block.timestamp), eternalStorage.getMediaRentDuration(_tokenId));
            emit RentStarted(_tokenId, eternalStorage.getCoOwners(_tokenId, _msgSender()));
        }
        emit PayForRent(_tokenId, _msgSender());
    }

    function rentByPeer(uint256 _tokenId, address mainRenter, bytes32[] memory proof) external payable {
        //        require(not rented now);
        require(eternalStorage.mediaRentStatus(_tokenId) == false, "media rented now");
        //        requeire(in merklepeers);
        bytes32 merkleTree = eternalStorage.getRentRequestMerkleTree(_tokenId, mainRenter);
        require(proof.verify(merkleTree, keccak256(abi.encodePacked(_msgSender()))), "Address not in list");
        // cummulatedPrice += single_peer_price;
        //        transfer_price_to_owner();
        //        save_this_add in transfereds;
        _forwardFunds(payable(NFT.ownerOf(_tokenId)));
        eternalStorage.savePaidInfo(_tokenId, mainRenter, _msgSender(), msg.value);
        if (eternalStorage.hasEveryOnePaid(_tokenId, mainRenter)) {
            eternalStorage.updateRentStatus(_tokenId);
            emit RentFinishTime(_tokenId, uint256(block.timestamp), eternalStorage.getMediaRentDuration(_tokenId));
            emit RentStarted(_tokenId, eternalStorage.getCoOwners(_tokenId, mainRenter));
        }
        emit PayForRent(_tokenId, _msgSender());
    }

    function renterAllowedToWatch(uint256 _tokenId, address mainRenter, bytes32[] memory proof) external returns (bool){
        bytes32 merkleTree = eternalStorage.getRentRequestMerkleTree(_tokenId, mainRenter);
        require(proof.verify(merkleTree, keccak256(abi.encodePacked(_msgSender()))), "Address not in list");
        return eternalStorage.hasEveryOnePaid(_tokenId, mainRenter);
    }

    function allowedToWatch(uint256 _tokenId) public view returns (bool){
        require(_msgSender() == NFT.ownerOf(_tokenId), "not owner");
        return true;
    }

    function getMediaRentPrice(uint256 _tokenId) public view returns (uint256){
        return eternalStorage.getMediaRentPrice(_tokenId);
    }

    function canRemovePeer(uint256 _tokenId, address mainRenter, address peer) external view returns (bool){
        return !eternalStorage.hasPaid(_tokenId, mainRenter, peer);
    }

    function getPaidRentCumulativeValue(uint256 _tokenId, address mainRenter) external view returns (uint256){
        return eternalStorage.getPaidRentCumulativeValue(_tokenId, mainRenter);
    }

    function resetRentStatus(uint256 _tokenId, address renter) external {
        eternalStorage.resetRentStatus(_tokenId, renter);
    }

    function isRented(uint256 _tokenId) public view returns (bool) {
        return eternalStorage.mediaRentStatus(_tokenId);
    }

    function getMediaInfo(uint256 _tokenId) public view override returns (bytes32, bytes32, uint256, uint256, uint256, uint256){
        return eternalStorage.getMediaInfo(_tokenId);
    }

    function _forwardFunds(address payable receiver) internal {
        receiver.transfer(msg.value);
    }

}