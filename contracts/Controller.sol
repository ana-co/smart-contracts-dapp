// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./NFTLibrary.sol";
import "./interface/IController.sol";
import "./Collection.sol";


contract Controller is AccessControlUpgradeable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");


    address public eternalStorage;

    address public dynamicNFTCollectionAddress;

    Collection NFT;

    /* ========== EVENTS ========== */

    event MintNFT(uint256 _tokenId, address _minter, string uri);


    function initialize(address _eternalStorage, address _dynamicNFTCollectionAddress) public initializer {
        eternalStorage = _eternalStorage;
        dynamicNFTCollectionAddress = _dynamicNFTCollectionAddress;
        NFT = Collection(dynamicNFTCollectionAddress);

        tokenId = 0;

        __AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function mint(string memory uri, bytes32 _title, bytes32 _description, uint256 _price) external override returns (uint256){

        tokenId = tokenId + 1;

        NFT.mint(_msgSender(), tokenId);
        NFT.setTokenURI(tokenId, uri);
        eternalStorage.saveMediaInfo(tokenId, _title, _description, _price);

        emit MintNFT(tokenId, _msgSender(), uri);

        return tokenId;
    }

    function buyNFT(uint256 _tokenId) external payable override {
        address seller = NFT.ownerOf(tokenId);
        address buyer = _msgSender();

        uint256 price = eternalStorage.getMediaPrice(_tokenId);

        require(
            msg.value >= price,
            "Not enough funds"
        );

        NFT.transferFrom(seller, buyer, _tokenId);

        _forwardFunds(payable(seller));
    }

    function getMediaInfo(uint256 _tokenId) public view override returns (bytes32, bytes32, uint256){
        return eternalStorage.getMediaInfo(_tokenId);
    }

    function _forwardFunds(address payable receiver) internal {
        receiver.transfer(msg.value);
    }

}