// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script --keystores $ETH_KEYSTORE --sender $ETH_FROM --broadcast --fork-url $SEPOLIA_RPC_URL script/2_DeployNPC.s.sol:Deploy
// forge verify-contract --chain 5 --etherscan-api-key $ETHERSCAN_API_KEY 0xb7539fbfcbe9e64e85ea865980cd47e0962aae6d src/Character.sol:Character


/// -----------------
/// FINAL CONTRACT ADDRESSES
/// -----------------
/// 20 = 0xF1eFc9e4C5238C5bCf3d30774480325893435a2A
/// 721 = 0x9A349CF5F69c12423111b729564D43022eC875F1

contract DemoERC20 is ERC20 {
    constructor() ERC20("Frog Coin", "FROG20") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract DemoNFT is ERC721 {
    constructor() ERC721("Frog NFT", "FROG721") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract Deploy is Script {
    function run() public {
        vm.startBroadcast();
        DemoERC20 frogcoin = new DemoERC20();
        DemoNFT fromtoken = new DemoNFT();
        vm.stopBroadcast();
    }
}
