// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IToken.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract KK is IToken, ERC20 {
    constructor() ERC20("KK", "KK") { }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}
