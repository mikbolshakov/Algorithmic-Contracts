// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardsToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("RewardsToken", "RTK") {
        _mint(msg.sender, initialSupply);
    }
}