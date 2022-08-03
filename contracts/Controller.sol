// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./NFTLibrary.sol";
import "./interface/IController.sol";
import "./Collection.sol";


contract Controller is IController, Initializable, AccessControlUpgradeable {

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using NFTLibrary for address;

    address public eternalStorage;

    address public dynamicNFTCollectionAddress;

    uint256 public tokenId;

    Collection NFT;

    /* ========== EVENTS ========== */

    event Mint(uint256 _tokenId, address _minter, string uri, bytes32 _title, bytes32 _description, uint256 _price);
    event BuyNFT(uint256 _tokenId, address from, address to);


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

        emit Mint(tokenId, _msgSender(), uri, _title, _description, _price);

        return tokenId;
    }

    function buyNFT(uint256 _tokenId) external payable override {
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

    function getMediaInfo(uint256 _tokenId) public view override returns (bytes32, bytes32, uint256){
        return eternalStorage.getMediaInfo(_tokenId);
    }

    function _forwardFunds(address payable receiver) internal {
        receiver.transfer(msg.value);
    }

}