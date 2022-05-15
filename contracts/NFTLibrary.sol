pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./storage/EternalStorage.sol";

library NFTLibrary {

    using SafeMath for uint256;

    function saveMediaInfo(address _storageContract, uint256 _tokenId, bytes32 _title, bytes32 _description, uint256 _price) public
    {
        EternalStorage(_storageContract).setBytes32Value(keccak256(abi.encodePacked("media_title", _tokenId)), _title);
        EternalStorage(_storageContract).setBytes32Value(keccak256(abi.encodePacked("media_description", _tokenId)), _description);
        EternalStorage(_storageContract).setUIntValue(keccak256(abi.encodePacked("media_price", _tokenId)), _price);
    }

    function getMediaInfo(address _storageContract, uint256 _tokenId) public view returns (bytes32, bytes32, uint256)
    {
        return
        (
        EternalStorage(_storageContract).getBytes32Value(keccak256(abi.encodePacked("media_title", _tokenId))),
        EternalStorage(_storageContract).getBytes32Value(keccak256(abi.encodePacked("media_description", _tokenId))),
        EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_price", _tokenId)))
        );
    }

    function getMediaPrice(address _storageContract, uint256 _tokenId) public view returns (uint256)
    {
        return EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_price", _tokenId)));
    }

}
