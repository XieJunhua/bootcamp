//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { BaseScript } from "./Base.s.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

abstract contract UpgradeableDeploy is BaseScript {
    uint256 public immutable privateKey;
    address public implementation;
    bytes public data;
    address public proxyAddress;

    error InvalidAddress(string reason);

    // create 的时候部署两个合约，一个是实现合约，一个是代理合约
    modifier create() {
        _;
        if (implementation == address(0)) {
            revert InvalidAddress("implementation address can not be zero");
        }
        proxyAddress = address(new ERC1967Proxy(implementation, data));
    }

    modifier upgrade() {
        _;
        if (proxyAddress == address(0)) {
            revert InvalidAddress("proxy address can not be zero");
        }
        if (implementation == address(0)) {
            revert InvalidAddress("implementation address can not be zero");
        }
        UUPSUpgradeable proxy = UUPSUpgradeable(proxyAddress);
        proxy.upgradeToAndCall(address(implementation), data);
    }

    constructor(uint256 pkey) {
        privateKey = pkey;
    }

    function run() external {
        vm.startBroadcast(privateKey);
        _run();
        vm.stopBroadcast();
    }

    function _run() internal virtual;
}
