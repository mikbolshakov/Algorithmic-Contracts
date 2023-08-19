// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface Player {
    function number() external returns (uint256);
}

contract MagicSequence {
    bool public accepted;
    bytes4[] private hashes;

    constructor() {
        hashes.push(0xbeced095);
        hashes.push(0x42a7b7dd);
        hashes.push(0x45e010b9);
        hashes.push(0xa86c339e);
    }

    function start() public returns (bool) {
        Player player = Player(msg.sender);

        uint8 i = 0;
        while (i < 4) {
            if (bytes4(uint32(uint256(keccak256(abi.encodePacked(player.number()))) >> 224)) != hashes[i]) {
                return false;
            }
            i++;
        }
        accepted = true;
        return true;
    }
}

contract Hacker is Player {
    uint256 counter = 0;
    MagicSequence target;

    constructor(address _target) {
        target = MagicSequence(_target);
    }

    function number() external override returns (uint256) {
        uint256 output;
        if (counter == 0) output = 42;
        if (counter == 1) output = 55;
        if (counter == 2) output = 256;
        if (counter == 3) output = 9876543;
        counter++;
        return output;
    }

    function hack() external {
        target.start();
    }
}
