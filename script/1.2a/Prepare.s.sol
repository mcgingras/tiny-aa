// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IWallet} from "../../src/IWallet.sol";
import {Wallet} from "../../src/Wallet.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";


// forge script script/1.2a/Prepare.s.sol:DeployScript --fork-url http://localhost:8545 --broadcast -i 1

contract DemoERC20 is ERC20 {
    constructor() ERC20("Demo ERC20", "DEMO20") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}


/// The point of this script is to ...
contract DeployScript is Script {
    address anvil1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address anvil2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function setUp() public {
    }

    function getSignature (uint256 pk, bytes32 digest) public returns (bytes memory) {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }

    function run() public {
        vm.startBroadcast();
        address[] memory owners = new address[](1);
        owners[0] = anvil1;
        Wallet wallet = new Wallet(owners);
        console.log(address(wallet));

        DemoERC20 demoERC20 = new DemoERC20();
        demoERC20.mint(address(wallet), 1000);
        console.log(address(demoERC20));

        address to = address(demoERC20);
        uint256 value = 0;
        uint256 gas = 0;
        bytes memory transferData = abi.encodeWithSignature("transfer(address,uint256)", anvil2, 1);

        uint256 nonce = wallet.getNonce();
        bytes32 digest = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(to,value,transferData,gas,nonce)));
        bytes memory signature = getSignature(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80, digest);
        IWallet.UserOperation memory op = IWallet.UserOperation(address(wallet), to, value, transferData, gas, signature, nonce);
        bytes memory data = abi.encodeWithSignature("executeOp((address,address,uint256,bytes,uint256,bytes,uint256))", op);
        console.logBytes(data);

        // address(wallet).call(data);
        // wallet.executeOp(op);
        vm.stopBroadcast();
    }
}
