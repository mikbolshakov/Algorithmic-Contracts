// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnglishAuction {
    string public item;
    address payable immutable seller;
    bool public started;
    bool public ended;
    uint256 endAt;
    uint256 public highestBid;
    address public highestBidder;
    mapping(address => uint256) public bids;

    event Start (string _item, uint256 _startingPrice);
    event LastBid(address _bidder, uint256 _bid);
    event End(address _highestBidder, uint256 _highestBid);
    event Withdraw(address _sender, uint256 _amount);

    constructor(string memory _item, uint256 _startingPrice) {
        seller = payable(msg.sender);
        item = _item;
        highestBid = _startingPrice;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "not a seller");
        _;
    }

    modifier notEnded() {
        require(!ended, "ended");
        _;
    }

    modifier hasStarted() {
        require(started, "not started yet");
        _;
    }

    function start() public onlySeller {
        require(!started, "already started");

        started = true;
        endAt = block.timestamp + 60;
        emit Start(item, highestBid);
    }

    function bid() public payable hasStarted notEnded {
        require(msg.value > highestBid, "too low bid");

        if(highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBid = msg.value;
        highestBidder = msg.sender;
        emit LastBid(msg.sender, msg.value);
    }

    function end() external hasStarted notEnded onlySeller {
        require(block.timestamp >= endAt, "to early to end");
        ended = true;

        if(highestBidder != address(0)) {
            seller.transfer(highestBid);
        }

        emit End(highestBidder, highestBid);
    }

    function withdrawBids() external {
        uint256 refundAmount = bids[msg.sender];
        require(refundAmount > 0, "nothing to refund");

        bids[msg.sender] = 0;
        payable(msg.sender).transfer(refundAmount);
        emit Withdraw(msg.sender, refundAmount);
    }
}