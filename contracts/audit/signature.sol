// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "hardhat/console.sol";

contract Signature {
    address public owner;
    address public previousOwner;

    constructor() {
        owner = msg.sender;
    }

    function executeTransaction(address _destination, uint256 _value, bytes memory _data) public {
        require(msg.sender == owner, "Not an owner");
        _destination.call{value: _value}(_data);
    }

    // New owner have to accept ownership by providing a signature from the owner
    function acceptOwnership(uint8 v, bytes32 r, bytes32 s) public {
        require(ecrecover(generateHash(owner), v, r, s) == owner, "You haven't provided a signature from the owner");
        previousOwner = owner;
        owner = msg.sender;
    }

    // Generates a hash compatible with EIP-191 signatures
    function generateHash(address _addr) public pure returns (bytes32) {
        bytes32 addressHash = keccak256(abi.encodePacked(_addr));
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", addressHash));
    }


    receive() external payable {}
}