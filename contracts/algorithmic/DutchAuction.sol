// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DutchAuction {
    uint256 constant DURATION = 2 days;
    address payable immutable seller;
    uint256 public immutable startingPrice;
    uint256 immutable startAt;
    uint256 immutable endAt;
    uint256 immutable discountRate;
    string public item;
    bool public stopped;

    constructor(
        uint256 _startingPrice,
        uint256 _discountRate,
        string memory _item
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        endAt = block.timestamp + DURATION;
        discountRate = _discountRate;
        item = _item;
        require(
            _startingPrice > _discountRate * DURATION,
            "starting price and discount are incorrect"
        );
    }

    modifier notStopped() {
        require(!stopped, "stopped");
        _;
    }

    function getPrice() public view notStopped returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable notStopped {
        require(block.timestamp < endAt, "ended");
        uint256 price = getPrice();
        require(msg.value >= price, "not enough funds");

        uint256 refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        seller.transfer(address(this).balance);
        stopped = true;
    }
}
