// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "./IEntryPoint.sol";

contract EntryPoint is IEntryPoint {
    mapping (address => uint256) public balances;

    // I don't think we need anything in the constructor atm?
    constructor() {}

    function handleOp(IWallet.UserOperation memory op) external {
        // 1. check that the wallet has enough funds to pay for the gas
        // question --
        // couldn't we just lie about the gas balance sent in op.gas? That way we can
        // have a really low balance, but then when we go to subtract the gas spent we will fail?
        // I feel like it's not safe to trust the gas value from the userOp. Maybe the bundler
        // Is supposed to run a simulation on their own.
        uint256 balance = balances[op.sender];
        require(balance >= op.gas, "EntryPoint: insufficient funds to pay for gas");

        // 2. call wallets executeOp method and get gas spend
        uint256 gasBefore = gasleft();
        IWallet(op.sender).executeOp(op);
        uint256 gasSpent = gasBefore - gasleft();

        // 3. send some of the wallet's ETH to the executor to pay for the gas
        // thinking there was something security wise about using transfer?
        // push pull could be better, even for executor (bundler)
        balances[op.sender] -= gasSpent;
        balances[msg.sender] += gasSpent;
    }

    function deposit(address wallet) payable external {
        balances[wallet] += msg.value;
    }

    // do we need to protect this from reentrancy?
    function withdrawTo(address payable destination) external {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        destination.transfer(amount);
    }
}
