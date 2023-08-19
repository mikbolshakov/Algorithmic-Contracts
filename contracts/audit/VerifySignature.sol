// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract VerifySignature {
    function verify(
        address _signer,
        bytes memory _sig
    ) public pure returns (bool) {
        bytes32 msgHash = generateHash(_signer);
        bytes32 signedMsgHash = ethSignedMessageHash(msgHash);

        return recover(signedMsgHash, _sig) == _signer;
    }

    function generateHash(address _addr) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_addr));
    }

    function ethSignedMessageHash(
        bytes32 _msgHash
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _msgHash)
            );
    }

    function recover(
        bytes32 _ethSignedMsgHash,
        bytes memory _sig
    ) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _splitSig(_sig);
        return ecrecover(_ethSignedMsgHash, v, r, s);
    }

    function _splitSig(
        bytes memory _sig
    ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "Invalid signature");
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
}
