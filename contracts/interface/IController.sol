// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IController {

    function handleMint(string memory url, bytes32 _title, bytes32 _description, uint256 _price) external returns (uint256);

    function getMediaInfo(uint256 tokenId) external returns (bytes32, bytes32, uint256);

}
