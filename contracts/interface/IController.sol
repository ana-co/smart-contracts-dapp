// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IController {

    function mint(string memory url, bytes32 _title, bytes32 _description, uint256 _price, uint256 rentPrice, uint256 rentDuration, uint256 videoDuration) external returns (uint256);

    function buyNFT(uint256 tokenId) external payable;

    function getMediaInfo(uint256 tokenId) external view returns (bytes32, bytes32, uint256, uint256, uint256, uint256);

}
