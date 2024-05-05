// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { ERC20, ERC20Permit } from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

contract MyERC2612 is ERC20Permit {
    constructor() ERC20("JunhuaToken", "JHT") ERC20Permit("JunhuaToken") { }

    function mint(address _to, uint256 _amount) external {
        _mint(_to, _amount);
    }
}
