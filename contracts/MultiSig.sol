// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Ownable {
    address[] public owners;
    mapping(address => bool) public isOwner;

    constructor(address[] memory _owners) {
        require(_owners.length > 0, "no owners");
        for (uint256 i; i < _owners.length; i++) {
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
    // required number of transaction approvals
    uint256 public requiredApprovals;
    struct Transaction {
        address _to;
        uint256 _value;
        bytes _data;
        bool _executed;
    }
    Transaction[] public transactions;

    // transaction index in array => number of approvals
    mapping(uint256 => uint256) public approvalsCount;
    // transaction index in array => user address => whether user approved transaction
    mapping(uint256 => mapping(address => bool)) public approved;

    event Deposit(address _from, uint256 _amount);
    event Submit(uint256 _txId);
    event Approve(address _owner, uint256 _txId);
    event Revoke(address _owner, uint256 _txId);
    event Executed(uint256 _txId);

    // confirmation that the transaction exists
    modifier txExists(uint256 _tx) {
        require(_tx < transactions.length, "not exist");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!_isApproved(_txId, msg.sender), "tx already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId]._executed, "tx already executed");
        _;
    }

    modifier wasApproved(uint256 _txId) {
        require(_isApproved(_txId, msg.sender), "tx not approved yet");
        _;
    }

    modifier enoughApprovals(uint256 _txId) {
        require(
            approvalsCount[_txId] >= requiredApprovals,
            "not enough approvals"
        );
        _;
    }

    constructor(
        address[] memory _owners,
        uint256 _requiredApprovals
    ) Ownable(_owners) {
        require(
            _requiredApprovals > 0 && _requiredApprovals <= _owners.length,
            "invalid approvals count"
        );
        requiredApprovals = _requiredApprovals;
    }

    // put the transaction in the queue for execution
    function submitTransaction(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external onlyOwners {
        Transaction memory newTx = Transaction({
            _to: _to,
            _value: _value,
            _data: _data,
            _executed: false
        });
        transactions.push(newTx);
        emit Submit(transactions.length - 1);
    }

    function deposit() public payable {
        emit Deposit(msg.sender, msg.value);
    }

    // input argument in the _data field of the transaction
    function encodeData(
        string memory _func,
        string memory _arg
    ) public pure returns (bytes memory) {
        return abi.encodeWithSignature(_func, _arg);
    }

    function approveTransaction(
        uint256 _txId
    )
        external
        onlyOwners
        txExists(_txId)
        notApproved(_txId)
        notExecuted(_txId)
    {
        approved[_txId][msg.sender] = true;
        approvalsCount[_txId] += 1;
        emit Approve(msg.sender, _txId);
    }

    function _isApproved(
        uint256 _txId,
        address _addr
    ) private view returns (bool) {
        return approved[_txId][_addr];
    }

    function revokeApproval(
        uint256 _txId
    )
        external
        onlyOwners
        txExists(_txId)
        notExecuted(_txId)
        wasApproved(_txId)
    {
        approved[_txId][msg.sender] = false;
        approvalsCount[_txId] -= 1;
        emit Revoke(msg.sender, _txId);
    }

    function executeTransaction(
        uint256 _txId
    ) external txExists(_txId) notExecuted(_txId) enoughApprovals(_txId) {
        Transaction storage myTx = transactions[_txId];
        (bool success, ) = myTx._to.call{value: myTx._value}(myTx._data);
        require(success, "tx failed");

        myTx._executed = true;
        emit Executed(_txId);
    }

    receive() external payable {
        deposit();
    }
}

// Receive a Transaction
contract Receiver {
    string public message;

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getMoney(string memory _msg) external payable {
        message = _msg;
    }
}
