// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Crowd {
    struct Campaign {
        address owner; // владелец стартапа
        uint goal; // сколько денег нужно собрать
        uint pledged; // сколько инвестировали на данный момент
        uint startAt;
        uint endAt;
        bool claimed; // забрал ли владалец деньги
    }

    IERC20 public immutable token;
    mapping(uint => Campaign) public campaigns; // индекс компании => компания
    uint public currentId;
    mapping(uint => mapping(address => uint)) public pledges; // индекс компании => адрес инвестора => сумма инвестиций
    uint public constant MAX_DURATION = 100 days;
    uint public constant MIN_DURATION = 1 days;

    event Launched(uint id, address owner, uint goal, uint startAt, uint endAt);
    event Cancel(uint id);
    event Pledged(uint id, address pledger, uint amount);
    event Unpledged(uint id, address pledger, uint amount);
    event Claimed(uint id);
    event Refunded(uint id, address pledger, uint amount);

    constructor(address _token) {
        token = IERC20(_token);
    }


    function lounch(uint _goal, uint _startAt, uint _endAt) external {
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

    function cancel(uint _id) external {
        Campaign memory campaign = campaigns[_id]; // memory, так как компанию не меняем, а просто смотрим значения
        require(msg.msg.sender == campaign.owner, "not an owner");
        require(block.timestamp >= campaign.startAt, "already started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id]; // storage, так как меняем значения компании
        require(block.timestamp >= campaign.startAt, "not started");
        require(block.timestamp < campaign.endAt, "ended");

        campaign.pledged += _amount;
        pledges[_id][msg.sender] += _amount;
        token.transferFrom(msg.sender, address(this), _amount);
        emit Pledged(_id, msg.sender, _amount);
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp < campaign.endAt, "ended");

        campaign.pledged -= _amount;
        pledges[_id][msg.sender] -= _amount;
        token.transfer(msg.sender, _amount);
        emit Unpledged(_id, msg.sender, _amount);
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(msg.sender == campaign.owner, "not an owner");
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged is too low");
        require(!campaign.claimed, "already claimed");

        campaign.claimed = true;
        token.transfer(msg.sender, campaign.pledged);
        emit Claimed(_id);
    }

    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "reached goal");

        uint pledgedAmount = pledges[_id][msg.sender];
        pledges[_id][msg.sender] = 0;
        token.transfer(msg.sender, pledgedAmount);
        emit Refunded(_id, msg.sender, pledgedAmount);
    }
}
