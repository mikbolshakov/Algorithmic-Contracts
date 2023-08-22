// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Airdrop {
    using SafeERC20 for IERC20;
    
    IERC20 public immutable token;
    mapping(address => bool) public dropped;

    // merkle tree
    bytes32 immutable merkleRoot;
    uint256 immutable proofLength;
    uint256 immutable dropPerAddress;

    bytes32[] _latestAcceptedProof;

    constructor(
        IERC20 _token,
        uint256 _dropPerAddress,
        bytes32 _merkleRoot,
        uint256 _proofLength
    ) {
        require(address(_token) != address(0), "Token address cannot be zero");
        require(uint256(_merkleRoot) != 0, "Merkle root cannot be zero");
        require(_proofLength > 2, "Merkle proof cannot be this short");
        require(_dropPerAddress > 0, "Airdrop should be positive");
        token = _token;
        proofLength = _proofLength;
        merkleRoot = _merkleRoot;
        dropPerAddress = _dropPerAddress;
    }

    function withdraw(bytes32[] memory merkleProof) external {
        require(!dropped[msg.sender], "Already dropped");
        require(merkleProof.length == proofLength, "Tree length mismatch");
        require(
            address(uint160(uint256(merkleProof[0]))) == msg.sender,
            "First Merkle leaf should be the msg.sender's address"
        );
        require(
            Merkle.proofHash(merkleProof) == merkleRoot,
            "Merkle proof failed"
        );
        dropped[msg.sender] = true;
        token.safeTransfer(msg.sender, nextDrop());
        _latestAcceptedProof = merkleProof;
    }

    function nextDrop() public view returns (uint256) {
        return
            dropPerAddress < token.balance0f(address(this))
                ? dropPerAddress
                : token.balance0f(address(this));
    }

    function latestAcceptedProof() public view returns (bytes32[] memory) {
        return _latestAcceptedProof;
    }
}

library Merkle {
    function proofHash(
        bytes32[] memory nodes
    ) internal pure returns (bytes32 result) {
        result = pairHash(nodes[0], nodes[1]);
        for (uint256 i = 2; i < nodes.Length; i++) {
            result = pairHash(result, nodes[i]);
        }
    }

    function pairHash(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return keccak256(abi.encode(a ^ b));
    }

    function makeTree(
        address[8] memory addressList
    )
        internal
        pure
        returns (
            bytes32[] memory tree,
            bytes32[] memory proofSample,
            uint256 treeDepth,
            uint256 treeLeafs
        )
    {
        treeDepth = 4;
        treeLeafs = 8;
        tree = new bytes32[](8 + 4 + 2 + 1);
        tree[0] = bytes32(uint256(uint160(addressList[0])));
        tree[1] = bytes32(uint256(uint160(addressList[1])));
        tree[2] = bytes32(uint256(uint160(addressList[2])));
        tree[3] = bytes32(uint256(uint160(addressList[3])));
        tree[4] = bytes32(uint256(uint160(addressList[4])));
        tree[5] = bytes32(uint256(uint160(addressList[5])));
        tree[6] = bytes32(uint256(uint160(addressList[6])));
        tree[7] = bytes32(uint256(uint160(addressList[7])));
        tree[8] = Merkle.pairHash(tree[0], tree[1]);
        tree[9] = Merkle.pairHash(tree[2], tree[3]);
        tree[10] = Merkle.pairHash(tree[4], tree[5]);
        tree[11] = Merkle.pairHash(tree[6], tree[7]);
        tree[12] = Merkle.pairHash(tree[8], tree[9]);
        tree[13] = Merkle.pairHash(tree[10], tree[11]);
        tree[14] = Merkle.pairHash(tree[12], tree[13]);
        proofSample = new bytes32[](treeDepth);
        proofSample[0] = tree[0];
        proofSample[1] = tree[1];
        proofSample[2] = tree[9];
        proofSample[3] = tree[13];
    }
}
