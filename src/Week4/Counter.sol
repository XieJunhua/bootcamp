// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract Counter is OwnableUpgradeable, UUPSUpgradeable {
    string public version;
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function initialize() public initializer {
        OwnableUpgradeable.__Ownable_init(msg.sender);
        version = "v1";
    }

    function increment() public {
        number++;
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner { } // solhint-disable-line
}
