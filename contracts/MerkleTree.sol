// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//                        All (6)
//      Rashford+Antony (4)     Shaw+Dalot (5)
// Rashford (0)     Antony(1)   Shaw (2)     Dalot (3)

contract MerkleTree {
    bytes32[] public hashes;
    string[4] players = ["Rashford", "Antony", "Shaw", "Dalot"];

    constructor() {
        for(uint256 i = 0; i < players.length; i++) {
            hashes.push(keccak256(abi.encodePacked(players[i])));
        }

        uint256 n = players.length;
        uint256 offset = 0;
        while (n > 0) {
            for(uint256 i = 0; i < n - 1; i += 2) {
                bytes32 newHash = keccak256(abi.encodePacked(
                    hashes[i + offset], hashes[i + offset + 1]
                ));
                hashes.push(newHash);
            }
            offset += n;
            n = n / 2;
        }
    }

    function getRootOurTree() public view returns(bytes32) {
        return hashes[hashes.length - 1];
    }

    function verifyElementInTree(bytes32 rootHash, bytes32 leafHash, uint256 index, bytes32[] memory proof) public pure returns (bool) {
        // check Shaw: leafHash = hashes[2]; index = 2; proof = [hashes[3], hashes[4]]
        bytes32 hash = leafHash;
        for(uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if(index % 2 == 0) {
                hash = keccak256(abi.encodePacked(
                    hash, proofElement
                ));
            } else {
                hash = keccak256(abi.encodePacked(
                    proofElement, hash
                ));
            }
            index = index / 2;
        }

        return hash == rootHash;
    }
}