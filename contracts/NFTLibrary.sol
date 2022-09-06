pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./storage/EternalStorage.sol";

library NFTLibrary {

    using SafeMath for uint256;

    function saveMediaInfo(address _storageContract, uint256 _tokenId, bytes32 _title, bytes32 _description, uint256 _price, uint256 rentPrice, uint256 rentDuration, uint256 videoDuration) public
    {
        EternalStorage(_storageContract).setBytes32Value(keccak256(abi.encodePacked("media_title", _tokenId)), _title);
        EternalStorage(_storageContract).setBytes32Value(keccak256(abi.encodePacked("media_description", _tokenId)), _description);
        EternalStorage(_storageContract).setUIntValue(keccak256(abi.encodePacked("media_price", _tokenId)), _price);
        EternalStorage(_storageContract).setUIntValue(keccak256(abi.encodePacked("media_rent_price", _tokenId)), rentPrice);
        EternalStorage(_storageContract).setUIntValue(keccak256(abi.encodePacked("media_rent_duration", _tokenId)), rentDuration);
        EternalStorage(_storageContract).setUIntValue(keccak256(abi.encodePacked("media_video_duration", _tokenId)), videoDuration);

    }

    function handleRentRequest(address _storageContract, uint256 _tokenId, address renter, bytes32 coOwners, uint256 numOfCoOwners, address[] memory coOwnersList, uint256 amount) public {
        EternalStorage(_storageContract).setBytes32Value(keccak256(abi.encodePacked("rent_request", _tokenId, renter)), coOwners);
        EternalStorage(_storageContract).setUIntValue(keccak256(abi.encodePacked("rent_request, num_of_co_owners", renter, _tokenId)), numOfCoOwners);
        EternalStorage(_storageContract).setAddressListValue(keccak256(abi.encodePacked("rent_request, coOwners_list", renter, _tokenId)), coOwnersList);
        uint256 paid = EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("rent_paid", renter, _tokenId)));
        EternalStorage(_storageContract).setUIntValue(keccak256(abi.encodePacked("rent_paid", renter, _tokenId)), amount + paid);
        EternalStorage(_storageContract).setBooleanValue(keccak256(abi.encodePacked("rent_paid_by_peer", renter, _tokenId, renter)), true);
    }

    function savePaidInfo(address _storageContract, uint256 _tokenId, address renter, address currentPeer, uint256 amount) public {
        uint256 paid = EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("rent_paid", renter, _tokenId)));
        EternalStorage(_storageContract).setUIntValue(keccak256(abi.encodePacked("rent_paid", renter, _tokenId)), paid + amount);
        EternalStorage(_storageContract).setBooleanValue(keccak256(abi.encodePacked("rent_paid_by_peer", renter, _tokenId, currentPeer)), true);
    }

    function hasPaid(address _storageContract, uint256 _tokenId, address renter, address currentPeer) public view returns (bool){
        return EternalStorage(_storageContract).getBooleanValue(keccak256(abi.encodePacked("rent_paid_by_peer", renter, _tokenId, currentPeer)));
    }

    function hasEveryOnePaid(address _storageContract, uint256 _tokenId, address renter) public returns (bool){
        uint256 totalPaid = EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("rent_paid", renter, _tokenId)));
        uint256 rentPrice = EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_rent_price", _tokenId)));
        return totalPaid >= rentPrice;
    }

    function mediaRentStatus(address _storageContract, uint256 _tokenId) public view returns (bool)
    {
        return EternalStorage(_storageContract).getBooleanValue(keccak256(abi.encodePacked("media_rent_status", _tokenId)));
    }

    function updateRentStatus(address _storageContract, uint256 _tokenId) public
    {
        EternalStorage(_storageContract).setBooleanValue(keccak256(abi.encodePacked("media_rent_status", _tokenId)), true);
    }

    function getRentRequestMerkleTree(address _storageContract, uint256 _tokenId, address renter) public view returns (bytes32)
    {
        return EternalStorage(_storageContract).getBytes32Value(keccak256(abi.encodePacked("rent_request", _tokenId, renter)));
    }

    function getCoOwners(address _storageContract, uint256 _tokenId, address renter) public view returns (address[] memory)
    {
        return EternalStorage(_storageContract).getAddressListValue(keccak256(abi.encodePacked("rent_request, coOwners_list", renter, _tokenId)));
    }

    function getMediaInfo(address _storageContract, uint256 _tokenId) public view returns (bytes32, bytes32, uint256, uint256, uint256, uint256)
    {
        return
        (
        EternalStorage(_storageContract).getBytes32Value(keccak256(abi.encodePacked("media_title", _tokenId))),
        EternalStorage(_storageContract).getBytes32Value(keccak256(abi.encodePacked("media_description", _tokenId))),
        EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_price", _tokenId))),
        EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_rent_price", _tokenId))),
        EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_rent_duration", _tokenId))),
        EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_video_duration", _tokenId)))

        );
    }

    function getMediaPrice(address _storageContract, uint256 _tokenId) public view returns (uint256)
    {
        return EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_price", _tokenId)));
    }

    function getMediaRentDuration(address _storageContract, uint256 _tokenId) public view returns (uint256){
        return EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_rent_duration", _tokenId)));
    }

    function getMediaRentPrice(address _storageContract, uint256 _tokenId) public view returns (uint256){
        return EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("media_rent_price", _tokenId)));
    }

    function getPaidRentCumulativeValue(address _storageContract, uint256 _tokenId, address renter) public view returns (uint256){
        return EternalStorage(_storageContract).getUIntValue(keccak256(abi.encodePacked("rent_paid", renter, _tokenId)));
    }


    function resetRentStatus(address _storageContract, uint256 _tokenId, address renter) public {
        EternalStorage(_storageContract).setBooleanValue(keccak256(abi.encodePacked("media_rent_status", _tokenId)), false);
        EternalStorage(_storageContract).setUIntValue(keccak256(abi.encodePacked("rent_paid", renter, _tokenId)), 0);
        address[] memory list = EternalStorage(_storageContract).getAddressListValue(keccak256(abi.encodePacked("rent_request, coOwners_list", renter, _tokenId)));
        for (uint i = 0; i < list.length; i++) {
            EternalStorage(_storageContract).setBooleanValue(keccak256(abi.encodePacked("rent_paid_by_peer", renter, _tokenId, list[i])), false);
        }


    }


}
