// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract DemoNFT is ERC721 {
    constructor() ERC721("Demo NFT", "DEMO721") {}

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}
