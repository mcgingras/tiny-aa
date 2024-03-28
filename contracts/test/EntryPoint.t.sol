// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Wallet} from "../src/Wallet.sol";
import {IWallet} from "../src/IWallet.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {DemoERC20} from "./helpers/DemoERC20.sol";
import {DemoNFT} from "./helpers/DemoERC721.sol";
import {EntryPoint} from "../src/EntryPoint.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract EntryPointTest is Test {
    Wallet public wallet;
    DemoNFT public demoNFT;
    DemoERC20 public demoERC20;
    EntryPoint public entryPoint;
    address public signer1;
    address public signer2;
    address public executor;
    uint256 internal signer1PK;
    uint256 internal signer2PK;
    uint256 internal executorPK;
    address public recipient;

    function setUp() public {
        (address s1, uint256 pk1) = makeAddrAndKey("signer1");
        (address s2, uint256 pk2) = makeAddrAndKey("signer2");
        (address e, uint256 pk3) = makeAddrAndKey("executor");
        signer1 = s1;
        signer2 = s2;
        executor = e;
        signer1PK = pk1;
        signer2PK = pk2;
        executorPK = pk3;
        recipient = address(333);
        address[] memory owners = new address[](2);
        owners[0] = signer1;
        owners[1] = signer2;
        entryPoint = new EntryPoint();
        wallet = new Wallet(owners, address(entryPoint));
        demoNFT = new DemoNFT();
        demoNFT.mint(address(wallet), 1);
        demoERC20 = new DemoERC20();
        demoERC20.mint(address(wallet), 1000);


        // sending eth to the wallet so it can pay gas
        vm.deal(signer1, 100 ether);
        vm.prank(signer1);
        address(wallet).call{value: 1 ether}("");
        entryPoint.deposit{value: 1 ether}(address(wallet));
    }

    function getSignature (uint256 pk, bytes32 digest) public returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }

    function test_ExecuteOpSuccessERC20() public {
        address to = address(demoERC20);
        uint256 value = 0;
        uint256 gas = 0;
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", recipient, 1);

        vm.startPrank(signer1);
        uint256 nonce = wallet.getNonce();
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,data,gas,nonce)));
        bytes memory signature = getSignature(signer1PK, digest);
        IWallet.UserOperation memory op = IWallet.UserOperation(address(wallet), to, value, data, gas, signature, nonce);
        entryPoint.handleOp(op);
        assertEq(demoERC20.balanceOf(recipient), 1);
        assertEq(demoERC20.balanceOf(address(wallet)), 999);
        vm.stopPrank();
    }

   function test_ExecuteOpSuccessERC721() public {
        uint256 nonce = wallet.getNonce();
        address to = address(demoNFT);
        uint256 value = 0;
        uint256 gas = 0;
        bytes memory data = abi.encodeWithSignature("transferFrom(address,address,uint256)", address(wallet), recipient, 1);

        vm.startPrank(signer1);
        bytes32 digest1 = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,data,gas,nonce)));
        bytes memory signature1 = getSignature(signer1PK, digest1);
        vm.stopPrank();

        vm.startPrank(signer2);
        bytes32 digest2 = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,data,gas,nonce)));
        bytes memory signature2 = getSignature(signer2PK, digest2);
        vm.stopPrank();

        bytes memory signature = abi.encodePacked(signature1, signature2);
        IWallet.UserOperation memory op = IWallet.UserOperation(address(wallet), to, value, data, gas, signature, nonce);

        entryPoint.handleOp(op);

        assertEq(demoNFT.ownerOf(1), recipient);
    }

    function test_ExecuteOpFailure_WrongSigner() public {
        (address signer, uint256 pk) = makeAddrAndKey("invalidSigner");
        vm.startPrank(signer1);
        uint256 nonce = wallet.getNonce();
        address to = address(demoERC20);
        uint256 value = 0;
        uint256 gas = 0;
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", recipient, 1);
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,data,gas,nonce)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        IWallet.UserOperation memory op = IWallet.UserOperation(address(wallet), to, value, data, gas, signature, nonce);

        vm.expectRevert();
        entryPoint.handleOp(op);
        vm.stopPrank();
    }

    function test_ExecuteOpFailure_InvalidOp() public {
        vm.startPrank(signer1);
        uint256 nonce = wallet.getNonce();
        address to = address(demoNFT);
        uint256 value = 0;
        bytes memory data = abi.encodeWithSignature("transferFrom(address,address,uint256)", address(wallet), recipient, 1);
        uint256 gas = 0;
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,data,gas,nonce)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer1PK, digest);
        bytes memory signature = abi.encodePacked(r, s, v);

        address forgedRecipient = address(444);
        bytes memory forgedData = abi.encodeWithSignature("transferFrom(address,address,uint256)", address(wallet), forgedRecipient, 1);

        IWallet.UserOperation memory op = IWallet.UserOperation(address(wallet), to, value, forgedData, gas, signature, nonce);
        vm.expectRevert();
        entryPoint.handleOp(op);
        vm.stopPrank();
    }

    function test_ExecutorPaidGasRefundOnSuccess() public {
        address to = address(demoERC20);
        uint256 value = 0;
        uint256 gas = 0;
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", recipient, 1);
        uint256 preExecutionBalance = address(executor).balance;

        vm.startPrank(executor);
        uint256 nonce1 = wallet.getNonce();
        bytes32 digest1 = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,data,gas,nonce1)));
        bytes memory signature1 = getSignature(signer1PK, digest1);
        IWallet.UserOperation memory op1 = IWallet.UserOperation(address(wallet), to, value, data, gas, signature1, nonce1);
        entryPoint.handleOp(op1);
        assertEq(demoERC20.balanceOf(recipient), 1);
        assertEq(demoERC20.balanceOf(address(wallet)), 999);

        address payable executorAddress = payable(address(executor));
        entryPoint.withdrawTo(executorAddress);
        uint256 postExecutionBalance = address(executor).balance;
        assertGt(postExecutionBalance, preExecutionBalance);
        vm.stopPrank();
    }

    function test_GriefWalletOwnerByDrainingDoesNotWork() public {
        (address signer, uint256 pk) = makeAddrAndKey("invalidSigner");
        address to = address(demoERC20);
        uint256 value = 0;
        uint256 gas = 0;
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", recipient, 1);
        uint256 preExecutionBalance = address(executor).balance;

        for (uint256 i = 0; i < 10; i++) {
            vm.startPrank(executor);
            uint256 nonce = wallet.getNonce();
            bytes32 digest = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,data,gas,nonce)));
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
            bytes memory signature = abi.encodePacked(r, s, v);
            IWallet.UserOperation memory op = IWallet.UserOperation(address(wallet), to, value, data, gas, signature, nonce);
            vm.expectRevert();
            entryPoint.handleOp(op);
            vm.stopPrank();
        }

        address payable executorAddress = payable(address(executor));
        entryPoint.withdrawTo(executorAddress);
        uint256 postExecutionBalance = address(executor).balance;
        assertEq(postExecutionBalance, preExecutionBalance);
        vm.stopPrank();
    }
}
