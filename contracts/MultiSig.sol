// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address[] public owners;
    mapping(address => bool) public isOwner; // адрес => является владельцем или нет

    constructor(address[] memory _owners) {
        require(_owners.length > 0, "no owners");
        for(uint i; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "zero address");
            require(!isOwner[owner], "not unique");
            isOwner[owner] = true;
            owners.push(owner);
        }
    }

    modifier onlyOwners() {
        require(isOwner[msg.sender], "not an owner");
        _;
    }
}



contract Multisig is Ownable {
    uint public requiredApprovals; // необходимое количество апрувов транзакции
    struct Transaction {
        address _to;
        uint _value;
        bytes _data;
        bool _executed;
    }
    Transaction[] public transactions;

    mapping(uint => uint) public approvalsCount; // индекс транзакции в массиве => количество апрувов
    mapping(uint => mapping(address => bool)) public approved; // индекс транзакции в массиве => адрес => апрувнул ли этот адрес эту транзакцию

    event Deposit(address _from, uint _amount);
    event Submit(uint _txId);
    event Approve(address _owner, uint _txId);  
    event Revoke(address _owner, uint _txId); 
    event Executed(uint _txId);

    // подтверждение, что транзакция существует
    modifier txExists(uint _tx) {
        require(_txId < transactions.length, "not exist");
        _;
    }

    modifier notApproved(uint _txId) {
        require(!_isApproved(_txId, msg.sender), "tx already approved");
        _;
    }

    modifier notExecuted(uint _txId) {
        require(!transactions[_txId]._executed, "tx already executed");
        _;
    }

    modifier wasApproved(uint _txId) {
        require(_isApproved(_txId, msg.sender), "tx not approved yet");
        _;
    }

    modifier enoughApprovals(uint _txId) {
        require(approvalsCount[_txId] >= requiredApprovals, "not enough approvals");
        _;
    }

    constructor(address[] memory _owners, uint _requiredApprovals) Ownable(_owners) {
        require(_requiredApprovals > 0 && _requiredApprovals <= _owners.length, "invalid approvals count");
        requiredApprovals = _requiredApprovals;
    }

    // ставим транзакцию в очередь на выполнение
    function submit(address _to, uint _value, bytes calldata _data) external onlyOwners {
        Transaction memory newTx = Transaction({
            _to: _to,
            _value: _value,
            _data: _data,
            _executed: false
        });
        transactions.push(newTx);
        emit Submit(transactions.length - 1);
    }

    // принимает дс
    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    // входные данные в поле data транзакции
    function encode(string memory _func, string memory _arg) public pure returns(bytes memory) {
        return abi.encodeWithSignature(_func, _arg);
    }

    function approve(uint _txId) external onlyOwners txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        approvalsCount[_txId] += 1;
        emit Approve(msg.sender, _txId);  
    }

    function _isApproved(uint _txId, address _addr) private view returns(bool) {
        return approved[_txId][_addr];
    }

    // отзываем апрув транзакции
    function revoke(uint _txId) external onlyOwners txExists(_txId) notExecuted(_txId) wasApproved(_txId) {
        approved[_txId][msg.sender] = false;
        approvalsCount[_txId] -= 1;
        emit Revoke(msg.sender, _txId);
    }

    // выполняет транзакцию
    function execute(uint _txId) external txExists(_txId) notExecuted(_txId) enoughApprovals(uint _txId) {
        Transaction storage myTx = transactions[_txId];
        (bool success,) = myTx._to.call{value: myTx._value}(myTx._data);
        require(success, "tx failed");

        myTx._executed = true;
        emit Executed(_txId);
    }

    receive() external payable {
        deposit();
    }
}

// принимает транзакцию
contract Recevier {
    string public message;

    function getBalance() public view returns(uint) {
        retunr address(this).balance;
    }

    function getMoney(string memory _msg) external payable {
        message = _msg;
    }
}