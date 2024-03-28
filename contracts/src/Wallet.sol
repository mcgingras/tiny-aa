// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./IWallet.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

// something that is not immediately clear to me...
// If we want to use different authentication methods for different operations
// how are we supposed to tell which method to use?
// ---
// in practice it feels weird that the order of the signatures matter and that we need to submit it all at once
// maybe you do this offline and the signature is stored, then it gets submitted once we have sufficient signatures?
// (is this how safe does it?)
contract Wallet is IWallet {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    uint256 public nonce;
    address[] public owners;
    address public entryPoint;

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    modifier requireFromEntryPointOrOwner() {
        _requireFromEntryPointOrOwner();
        _;
    }

    constructor(address[] memory _owners, address _entryPoint) {
        owners = _owners;
        entryPoint = _entryPoint;
    }

    /// Modifiers

    function isOwner (address account) public view returns (bool) {
        for (uint256 i = 0; i < owners.length; i++) {
            if (account == owners[i]) {
                return true;
            }
        }
        return false;
    }

    function _onlyOwner() internal view {
        //directly from EOA owner, or through the account itself (which gets redirected through execute())
        bool owner = isOwner(msg.sender);
        require(owner || msg.sender == address(this), "only owner");
    }

    function _requireFromEntryPointOrOwner() internal view {
        require(msg.sender == entryPoint || isOwner(msg.sender), "account: not Owner or EntryPoint");
    }

    /// Functions

    function getNonce() external view returns (uint256) {
        return nonce;
    }

    function validateOp(UserOperation memory op) external returns (bool) {
       bool verified = false;
        bytes32 hash = keccak256(abi.encodePacked(op.to, op.value, op.data, op.gas, op.nonce));

        // if it's a 721 transfer, we need all the owners to sign
        // otherwise, we are okay with just a single signer signing
        if (_is721TransferOp(op.data)) {
            for (uint256 i = 0; i < owners.length; i++) {
                // Calculate the starting position of the 65-byte slot
                uint256 startIndex = i * 65;
                // Extract the 65-byte slot from the signature
                bytes memory signatureSlot = _sliceBytes(op.signature, startIndex, 65);
                bool isVerified = _verify(hash, signatureSlot, owners[i]);
                if (!isVerified) {
                    revert("Wallet: signatures invalid inner.");
                }
            }
            verified = true;
        } else {
            bytes memory signatureSlot = _sliceBytes(op.signature, 0, 65);
            address recovered = _recover(hash, signatureSlot);
            // check if the recovered address is one of the owners
            for (uint256 i = 0; i < owners.length; i++) {
                if (recovered == owners[i]) {
                    verified = true;
                    break;
                }
            }
        }

        return verified;
    }

    /// Only allow the owner or the trusted entry point to execute operations
    function executeOp(UserOperation memory op) external requireFromEntryPointOrOwner() {
        // check to make sure nonce has not been used
        if (op.nonce < nonce) {
            revert("Wallet: nonce too low");
        }

        // increment nonce
        nonce += 1;

        (bool success, ) = op.to.call{value: op.value}(op.data);
        require(success, "Wallet: operation failed");
    }

     function _returnGasSpent(uint256 gasSpent) internal {
        payable(msg.sender).call{value: gasSpent}("");
    }

    function _is721TransferOp(bytes memory data) internal pure returns (bool) {
        require(data.length >= 4, "Wallet: data too short");
        bytes4 selector;
        assembly {
            selector := mload(add(data, 32))
        }
        return selector == bytes4(keccak256("transferFrom(address,address,uint256)"));
    }

    function _recover(bytes32 data, bytes memory signature) internal pure returns (address) {
        return data
            .toEthSignedMessageHash()
            .recover(signature);
    }


    function _verify(bytes32 data, bytes memory signature, address account) internal pure returns (bool) {
        return _recover(data, signature) == account;
    }

    function _sliceBytes(bytes memory _bytes, uint256 _start, uint256 _length) internal pure returns (bytes memory) {
        require(_start + _length <= _bytes.length, "Invalid slice parameters");
        bytes memory sliced = new bytes(_length);
        for (uint256 i = 0; i < _length; i++) {
            sliced[i] = _bytes[_start + i];
        }
        return sliced;
    }

    // this is to make sure the contract can receive ether
    // Todo: add note on the purpose of this?
    receive() external payable {}
}
