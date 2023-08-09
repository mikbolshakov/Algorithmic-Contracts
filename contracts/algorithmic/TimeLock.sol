// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Postponing the execution of a transaction for a certain period
contract TimeLock {
    address public owner;
    uint256 constant MIN_DELAY = 10;
    uint256 constant MAX_DELAY = 100;
    // expired transaction time
    uint256 constant EXPIRY_DELAY = 1000;

    mapping(bytes32 => bool) public queuedTxs;

    event Queued(
        bytes32 indexed txId,
        address indexed to,
        uint256 value,
        string func,
        bytes data,
        uint256 timestamp
    );

    event Executed(
        bytes32 indexed txId,
        address indexed to,
        uint256 value,
        string func,
        bytes data,
        uint256 timestamp
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "not an owner");
        _;
    }

    // put the transaction in the queue (encode and add to the mapping)
    function queue(
        address _to, // Runner contract address
        uint256 _value,
        string calldata _func, // Runner: function run
        bytes calldata _data, // Runner: prepareData function result
        uint256 _timestamp // Runner: newTimestamp function result
    ) external onlyOwner returns (bytes32) {
        bytes32 txId = keccak256(
            abi.encode(_to, _value, _func, _data, _timestamp)
        );
        require(!queuedTxs[txId], "already queued");
        require(
            _timestamp >= block.timestamp + MIN_DELAY &&
                _timestamp <= block.timestamp + MAX_DELAY,
            "invalid timestamp"
        );
        queuedTxs[txId] = true;

        emit Queued(txId, _to, _value, _func, _data, _timestamp);

        return txId;
    }

    function executeTransaction(
        address _to,
        uint256 _value,
        string calldata _func,
        bytes calldata _data,
        uint256 _timestamp
    ) external payable onlyOwner returns (bytes memory) {
        bytes32 txId = keccak256(
            abi.encode(_to, _value, _func, _data, _timestamp)
        );
        require(queuedTxs[txId], "not queued");
        require(block.timestamp >= _timestamp, "too early");
        require(block.timestamp <= _timestamp + EXPIRY_DELAY, "too late");

        delete queuedTxs[txId];

        bytes memory data;
        if (bytes(_func).length > 0) {
            data = abi.encodePacked(bytes4(keccak256(bytes(_func))), _data);
        } else {
            data = _data;
        }

        (bool success, bytes memory resp) = _to.call{value: _value}(data);
        require(success, "tx failed");

        emit Executed(txId, _to, _value, _func, _data, _timestamp);

        return resp;
    }

    function cancelTransaction(bytes32 _txId) external onlyOwner {
        require(queuedTxs[_txId], "not queued");

        delete queuedTxs[_txId];
    }
}

contract Runner {
    address public lock; // TimeLock address
    string public message;
    mapping(address => uint256) public payments;

    constructor(address _lock) {
        lock = _lock;
    }

    function run(string memory newMsg) external payable {
        require(msg.sender == lock, "invalid address");

        payments[msg.sender] += msg.value;
        message = newMsg;
    }

    function newTimestamp() external view returns (uint256) {
        return block.timestamp + 20;
    }

    function prepareData(
        string calldata _msg
    ) external pure returns (bytes memory) {
        return abi.encode(_msg);
    }
}
