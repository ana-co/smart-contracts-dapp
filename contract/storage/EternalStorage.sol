// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Inheritance
import "./Owned.sol";
import "./State.sol";

// https://docs.synthetix.io/contracts/source/contracts/eternalstorage
/**
 * @notice  This contract is based on the code available from this blog
 * https://blog.colony.io/writing-upgradeable-contracts-in-solidity-6743f0eecc88/
 * Implements support for storing a keccak256 key and value pairs. It is the more flexible
 * and extensible option. This ensures data schema changes can be implemented without
 * requiring upgrades to the storage contract.
 */
contract EternalStorage is Owned, State {

    constructor(address _owner, address _associatedContract) Owned(_owner) State(_associatedContract) {}

    /* ========== DATA TYPES ========== */
    mapping(bytes32 => uint) internal UIntStorage;

    mapping(bytes32 => uint16) internal UInt16Storage;
    mapping(bytes32 => string) internal StringStorage;
    mapping(bytes32 => address) internal AddressStorage;
    mapping(bytes32 => bytes) internal BytesStorage;
    mapping(bytes32 => bytes32) internal Bytes32Storage;
    mapping(bytes32 => bool) internal BooleanStorage;
    mapping(bytes32 => int) internal IntStorage;


    function getUIntValue(bytes32 record) external view returns (uint) {
        return UIntStorage[record];
    }

    function setUIntValue(bytes32 record, uint value) external onlyAssociatedContract {
        UIntStorage[record] = value;
    }

    function deleteUIntValue(bytes32 record) external onlyAssociatedContract {
        delete UIntStorage[record];
    }

    function getUInt16Value(bytes32 record) external view returns (uint16) {
        return UInt16Storage[record];
    }

    function setUInt16Value(bytes32 record, uint16 value) external onlyAssociatedContract {
        UInt16Storage[record] = value;
    }

    function deleteUInt16Value(bytes32 record) external onlyAssociatedContract {
        delete UInt16Storage[record];
    }

    function getStringValue(bytes32 record) external view returns (string memory) {
        return StringStorage[record];
    }

    function setStringValue(bytes32 record, string calldata value) external onlyAssociatedContract {
        StringStorage[record] = value;
    }

    function deleteStringValue(bytes32 record) external onlyAssociatedContract {
        delete StringStorage[record];
    }

    function getAddressValue(bytes32 record) external view returns (address) {
        return AddressStorage[record];
    }

    function setAddressValue(bytes32 record, address value) external onlyAssociatedContract {
        AddressStorage[record] = value;
    }

    function deleteAddressValue(bytes32 record) external onlyAssociatedContract {
        delete AddressStorage[record];
    }

    function getBytesValue(bytes32 record) external view returns (bytes memory) {
        return BytesStorage[record];
    }

    function setBytesValue(bytes32 record, bytes calldata value) external onlyAssociatedContract {
        BytesStorage[record] = value;
    }

    function deleteBytesValue(bytes32 record) external onlyAssociatedContract {
        delete BytesStorage[record];
    }

    function getBytes32Value(bytes32 record) external view returns (bytes32) {
        return Bytes32Storage[record];
    }

    function setBytes32Value(bytes32 record, bytes32 value) external onlyAssociatedContract {
        Bytes32Storage[record] = value;
    }

    function deleteBytes32Value(bytes32 record) external onlyAssociatedContract {
        delete Bytes32Storage[record];
    }

    function getBooleanValue(bytes32 record) external view returns (bool) {
        return BooleanStorage[record];
    }

    function setBooleanValue(bytes32 record, bool value) external onlyAssociatedContract {
        BooleanStorage[record] = value;
    }

    function deleteBooleanValue(bytes32 record) external onlyAssociatedContract {
        delete BooleanStorage[record];
    }

    function getIntValue(bytes32 record) external view returns (int) {
        return IntStorage[record];
    }

    function setIntValue(bytes32 record, int value) external onlyAssociatedContract {
        IntStorage[record] = value;
    }

    function deleteIntValue(bytes32 record) external onlyAssociatedContract {
        delete IntStorage[record];
    }
}
