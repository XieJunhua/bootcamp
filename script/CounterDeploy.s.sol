//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Counter } from "../src/Week4/Counter.sol";
import { CounterV2 } from "../src/Week4/CounterV2.sol";

import { BaseScript } from "./Base.s.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

abstract contract DeployScript is BaseScript {
    uint256 public immutable privateKey;
    address public implementation;
    bytes public data;
    address public proxyAddress;

    error InvalidAddress(string reason);

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

contract DeployCounterV1 is DeployScript {
    address private immutable _deployer;

    constructor() DeployScript(vm.envUint("PRIVATE_KEY")) {
        _deployer = vm.envAddress("DEPLOYER");
    }

    //slither-disable-next-line reentrancy-no-eth
    function _run() internal override create {
        Counter c = new Counter();
        implementation = address(c);
        data = bytes.concat(c.initialize.selector);
    }
}

contract DeployCounterV2 is DeployScript {
    constructor() DeployScript(vm.envUint("PRIVATE_KEY")) {
        proxyAddress = vm.envAddress("PROXY");
    }

    //slither-disable-next-line reentrancy-no-eth
    function _run() internal override upgrade {
        CounterV2 c = new CounterV2();
        implementation = address(c);
        data = bytes.concat(c.upgrade.selector);
    }
}
