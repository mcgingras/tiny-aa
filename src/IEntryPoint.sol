// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IWallet } from "./IWallet.sol";

interface IEntryPoint {
    function handleOp(IWallet.UserOperation memory op) external;
    function deposit(address wallet) payable external;
    function withdrawTo(address payable destination) external;
}
