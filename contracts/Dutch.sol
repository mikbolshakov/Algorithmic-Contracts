// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dutch {
    uint constant DURATION = 2 days;
    address payable immutable seller;
    uint public immutable startingPrice;
    uint immutable startAt;
    uint immutable endAt;
    uint immutable discountRate;
    string public item;
    bool public stopped;

    constructor(uint _startingPrice, uint _discountRate, string memory _item) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        endAt = block.timestamp + DURATION;
        discountRate = _discountRate;
        item = _item;
        require(_startingPrice > _discountRate * DURATION, "starting price and discount are incorrect");
    }

    modifier notStopped() {
        require(!stopped, "stopped");
        _;
    }

    function getPrice() public view notStopped returns(uint) {
        uint timeElapsed = block.timestamp - startAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable notStopped {
        require(block.timestamp < endAt, "ended");
        uint price = getPrice();
        require(msg.value >= price, "not enough funds");

        uint refund = msg.value - price;
        if(refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        seller.transfer(address(this).balance);
        stopped = true;
    }



}