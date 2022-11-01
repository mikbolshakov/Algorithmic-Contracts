// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract TokenReward is ERC20 {
    constructor() ERC20("TokenReward", "TRW", 10000) {}
}