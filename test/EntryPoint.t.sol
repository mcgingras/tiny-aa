// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";
import {IWallet} from "../src/IWallet.sol";
import {IEntryPoint} from "../src/IEntryPoint.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import {DemoNFT} from "./helpers/DemoERC721.sol";
import {DemoERC20} from "./helpers/DemoERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


contract EntryPointTest is Test {
    EntryPoint public entryPoint;
    Wallet public wallet;
    DemoNFT public demoNFT;
    DemoERC20 public demoERC20;
    address public signer1;
    address public signer2;
    uint256 internal signer1PK;
    uint256 internal signer2PK;
    address public recipient;

    // setup the wallet with 20s and 721s
    // setup signers
    function setUp() public {
        (address s1, uint256 pk1) = makeAddrAndKey("signer1");
        (address s2, uint256 pk2) = makeAddrAndKey("signer2");
        signer1 = s1;
        signer2 = s2;
        signer1PK = pk1;
        signer2PK = pk2;
        recipient = address(333);
        address[] memory owners = new address[](2);
        owners[0] = signer1;
        owners[1] = signer2;
        entryPoint = new EntryPoint();
        wallet = new Wallet(owners);
        demoNFT = new DemoNFT();
        demoNFT.mint(address(wallet), 1);
        demoERC20 = new DemoERC20();
        demoERC20.mint(address(wallet), 1000);
    }

    function getSignature (uint256 pk, bytes32 digest) public returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }

    function test_EntryPointFailsIfNotEnoughGas() public {
        address to = address(demoERC20);
        uint256 value = 0;
        uint256 gas = 0;
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", recipient, 1);

        vm.startPrank(signer1);
        uint256 nonce = wallet.getNonce();
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,data,gas,nonce)));
        bytes memory signature = getSignature(signer1PK, digest);
        IWallet.UserOperation memory op = IWallet.UserOperation(address(wallet), to, value, data, gas, signature, nonce);

        vm.expectRevert();
        entryPoint.handleOp(op);
        vm.stopPrank();
    }

    function test_EntryPointSucceeds() public {
        address to = address(demoERC20);
        uint256 value = 0;
        uint256 gas = 1000;
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", recipient, 1);

        vm.deal(signer1, 100 ether);
        vm.startPrank(signer1);
        uint256 nonce = wallet.getNonce();
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,data,gas,nonce)));
        bytes memory signature = getSignature(signer1PK, digest);
        IWallet.UserOperation memory op = IWallet.UserOperation(address(wallet), to, value, data, gas, signature, nonce);

        entryPoint.deposit{value: 100000}(address(wallet));
        entryPoint.handleOp(op);

        assertEq(demoERC20.balanceOf(recipient), 1);
        assertEq(demoERC20.balanceOf(address(wallet)), 999);

        // maybe check for gas spent?
        vm.stopPrank();
    }


    function test_Withdraw() public {
        vm.deal(signer1, 100 ether);
        vm.startPrank(signer1);
        uint256 preDepositBalance = address(signer1).balance;
        assertEq(preDepositBalance, 100 ether);

        entryPoint.deposit{value: 1 ether}(address(signer1));
        uint256 postDepositBalance = address(signer1).balance;
        assertEq(postDepositBalance, 99 ether);

        entryPoint.withdrawTo(payable(signer1));
        uint256 postWithdrawBalance = address(signer1).balance;
        assertEq(postWithdrawBalance, 100 ether);
        vm.stopPrank();
    }
}
