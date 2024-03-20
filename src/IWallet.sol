// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

interface IWallet {
    struct UserOperation {
        address sender;
        address to;
        uint256 value;
        bytes data;
        uint256 gas;
        bytes signature;
        uint256 nonce;
    }

    function executeOp(UserOperation memory op) external;
}
