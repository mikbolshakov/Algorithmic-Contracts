// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ContractStaking {
    IERC20 public rewardsToken;
    IERC20 public stakingToken;

    // Minimum of last updated time and reward finish time
    uint256 lastUpdateTime;
    // Reward to be paid out per second
    uint256 rewardRate = 10;
    // Sum of (reward rate * dt * 1e18 / total supply)
    uint256 rewardPerTokenStored;
    // User address => rewardPerTokenStored
    mapping(address => uint256) userRewardPerTokenPaid;
    // User address => rewards to be claimed
    mapping(address => uint256) rewards;

    // Total staked
    uint256 totalSupply;
    // User address => staked amount
    mapping(address => uint256) balances;

    modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = block.timestamp;
        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPerTokenPaid[_account] = rewardPerTokenStored;
        }
        _;
    }

    constructor(address _stakingToken, address _rewardsToken) {
        stakingToken = IERC20(_stakingToken);
        rewardsToken = IERC20(_rewardsToken);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply == 0) {
            return 0;
        }

        return
            rewardPerTokenStored +
            ((rewardRate * (block.timestamp - lastUpdateTime)) * 1e18) /
            totalSupply;
    }

    function stake(uint256 _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        stakingToken.transferFrom(msg.sender, address(this), _amount);
        totalSupply += _amount;
        balances[msg.sender] += _amount;
    }

    function withdraw(uint256 _amount) external updateReward(msg.sender) {
        require(
            _amount <= balances[msg.sender],
            "put less than you want to take"
        );
        totalSupply -= _amount;
        balances[msg.sender] -= _amount;
        stakingToken.transfer(msg.sender, _amount);
    }

    function earned(address _account) public view returns (uint256) {
        return
            ((balances[_account] *
                (rewardPerToken() - userRewardPerTokenPaid[_account])) / 1e18) +
            rewards[_account];
    }

    function getReward() external updateReward(msg.sender) {
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.transfer(msg.sender, reward);
        }
    }
}
