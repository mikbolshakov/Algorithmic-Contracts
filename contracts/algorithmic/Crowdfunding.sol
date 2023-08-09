// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Crowdfunding {
    struct Campaign {
        address owner;
        uint256 goal; // how much money to raise
        uint256 pledged; // how much money raised so far
        uint256 startAt;
        uint256 endAt;
        bool claimed; // did the owner take the money
    }

    IERC20 public immutable token;
    uint256 public currentId;
    uint256 public constant MAX_DURATION = 100 days;
    uint256 public constant MIN_DURATION = 1 days;
    // index of Campaign => Campaign
    mapping(uint256 => Campaign) public campaigns;
    // index of Campaign => investor address => amount of investment
    mapping(uint256 => mapping(address => uint256)) public pledges;

    event Launched(
        uint256 id,
        address owner,
        uint256 goal,
        uint256 startAt,
        uint256 endAt
    );
    event Cancel(uint256 id);
    event Pledged(uint256 id, address pledger, uint256 amount);
    event Unpledged(uint256 id, address pledger, uint256 amount);
    event Claimed(uint256 id);
    event Refunded(uint256 id, address pledger, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function lounch(uint256 _goal, uint256 _startAt, uint256 _endAt) external {
        require(_startAt >= block.timestamp, "incorrect lounch time");
        require(_endAt >= _startAt + MIN_DURATION, "incorrect end time");
        require(_endAt <= _startAt + MAX_DURATION, "too long duration");

        campaigns[currentId] = Campaign({
            owner: msg.sender,
            goal: _goal,
            pledged: 0,
            startAt: _startAt,
            endAt: _endAt,
            claimed: false
        });

        currentId += 1;
        emit Launched(currentId, msg.sender, _goal, _startAt, _endAt);
    }

    function cancel(uint256 _id) external {
        Campaign memory campaign = campaigns[_id];
        require(msg.sender == campaign.owner, "not an owner");
        require(block.timestamp >= campaign.startAt, "already started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp < campaign.endAt, "ended");

        campaign.pledged += _amount;
        pledges[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledged(_id, msg.sender, _amount);
    }

    function unpledge(uint256 _id, uint256 _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.endAt, "ended");

        campaign.pledged -= _amount;
        pledges[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
        emit Unpledged(_id, msg.sender, _amount);
    }

    function claim(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.owner, "not an owner");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged is too low");
        require(!campaign.claimed, "already claimed");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);
        emit Claimed(_id);
    }

    function refund(uint256 _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "reached goal");

        uint256 pledgedAmount = pledges[_id][msg.sender];
        pledges[_id][msg.sender] = 0;
        token.transfer(msg.sender, pledgedAmount);
        emit Refunded(_id, msg.sender, pledgedAmount);
    }
}
