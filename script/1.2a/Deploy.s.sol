// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";


// forge script script/1.2a/Deploy.s.sol:DeployScript --fork-url http://localhost:8545 --broadcast -i 1

contract DemoERC20 is ERC20 {
    constructor() ERC20("Demo ERC20", "DEMO20") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

/// The point of this script is to deploy the DemoERC20 and mint some tokens to our signer.
/// This way, we have a proper local node state for simulating a userOp.
/// Remember that we already deployed the wallet as well (which we could have done in this script too).
contract DeployScript is Script {
    address anvil1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function setUp() public {
    }

    function run() public {
        vm.startBroadcast();
        DemoERC20 demoERC20 = new DemoERC20();
        demoERC20.mint(anvil1, 1000);
        console.log(address(demoERC20));
        console.log(demoERC20.balanceOf(anvil1));
        vm.stopBroadcast();
    }
}
