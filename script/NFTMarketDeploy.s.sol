//SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { NFTMarketV1 } from "../src/Week4/NFTMarketV1.sol";
import { NFTMarketV2 } from "../src/Week4/NFTMarketV2.sol";
import { UpgradeableDeploy, BaseScript } from "./UpgrateableDeploy.s.sol";
import { BaseERC20 } from "../src/Week2/BaseERC20.sol";
import { MyERC721 } from "../src/Week2/MyERC721.sol";

contract NFTMarketV1Deploy is UpgradeableDeploy {
    address private immutable _deployer;

    constructor() UpgradeableDeploy(vm.envUint("PRIVATE_KEY")) {
        _deployer = vm.envAddress("DEPLOYER");
    }

    function _run() internal override create {
        NFTMarketV1 c = new NFTMarketV1();
        implementation = address(c);
        BaseERC20 token = new BaseERC20(vm.envAddress("ETH_FROM"));
        MyERC721 myNFT = new MyERC721();
        data = abi.encodeWithSignature("initialize(address,address)", address(myNFT), address(token));

        // .concat(address(token));
    }
}

contract NFTMarketV2Deploy is UpgradeableDeploy {
    constructor() UpgradeableDeploy(vm.envUint("PRIVATE_KEY")) {
        proxyAddress = vm.envAddress("PROXY");
    }

    function _run() internal override upgrade {
        NFTMarketV2 c = new NFTMarketV2();
        implementation = address(c);
        data = bytes.concat(c.upgrade.selector);
    }
}
