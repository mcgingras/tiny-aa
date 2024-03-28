// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// -----------------
/// SCRIPTS
/// -----------------
// forge script script/DeployTokens.s.sol:Deploy --fork-url http://localhost:8545 --broadcast --private-key $PRIVATE_KEY_1

/// -----------------
/// FINAL CONTRACT ADDRESSES
/// -----------------
/// 20 = 0x5FbDB2315678afecb367f032d93F642f64180aa3
/// 721 = 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512

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
