// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract TokenStake is ERC20 {
    constructor() ERC20("TokenStake", "TS", 100000) {}
}