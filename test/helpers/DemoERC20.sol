// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DemoERC20 is ERC20 {
    constructor() ERC20("Demo ERC20", "DEMO20") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
