// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

contract CounterV2 is OwnableUpgradeable, UUPSUpgradeable {
    string public version;
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function initialize() public initializer {
        // OwnableUpgradeable.__Ownable_init();
        version = "v2";
    }

    function upgrade() public {
        // OwnableUpgradeable.__Ownable_init();
        version = "v2";
    }

    function increment() public {
        number++;
        number++;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }

    function tryGetNumber() public view returns (uint256) {
        return number;
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner { } // solhint-disable-line
}
