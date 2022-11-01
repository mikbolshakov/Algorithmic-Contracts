// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC20.sol";

contract Staking {
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    uint rewardRate = 10;
    uint lastUpdateTime;
    uint rewardPerTokenStored;

    mapping(address => uint) userRewardPerTokenPaid;
    mapping(address => uint) rewards;

    mapping(address => uint) private balances;
    uint private totalSupply;

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        rewards[_account] = earned(_account);
        userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        _;
    }

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    function putInStake(uint _amount) external updateReward(msg.sender) {
        totalSupply += _amount;
        balances[msg.sender] += _amount;
        stakingToken.transferFrom(msg.sender, address(this), _amount); // need approve
    }

    function withdrawFromStake(uint _amount) external updateReward(msg.sender) {
        require(_amount <= balances[msg.sender], "put less than you want to take"); // ????
        totalSupply -= _amount;
        balances[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        rewardsToken.transfer(msg.sender, reward);
    }

    function rewardPerToken() public view returns(uint) {
        if(totalSupply == 0) {
            return 0;
        }

        return rewardPerTokenStored + (
            rewardRate * (block.timestamp - lastUpdateTime)
            ) * 1e18 / totalSupply;
    }

    function earned(address _account) public view returns(uint) {
        return (
            balances[_account] * (
            rewardPerToken() - userRewardPerTokenPaid[_account]
            ) / 1e18
        ) + rewards[_account];
    }
}