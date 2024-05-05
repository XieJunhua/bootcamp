// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// import { Initializable } from "@openzeppelin/contracts/contracts/Initializable.sol";

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
// import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import { ERC20Detailed } from "@openzeppelin/contracts/token/ERC20/ERC20Detailed.sol";

contract MyERC20 is Initializable, ERC20Upgradeable {
    function initialize(string memory name, string memory symbol, uint256 initialSupply) public initializer {
        __ERC20_init(name, symbol);
        _mint(_msgSender(), initialSupply);
    }
}
