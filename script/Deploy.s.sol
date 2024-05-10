// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { NFTMarket, BaseERC20 } from "../src/Week2/NFTMarket.sol";
import { MyERC721 } from "../src/Week2/MyERC721.sol";

import { BaseScript } from "./Base.s.sol";

/// @dev See the Solidity Scripting tutorial: https://book.getfoundry.sh/tutorials/solidity-scripting
contract NFTMarketDeploy is BaseScript {
    function run() public {
        uint256 deployPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployPrivateKey);
        BaseERC20 token = new BaseERC20(vm.envAddress("ETH_FROM"));
        // MyERC721 myNFT = new MyERC721();

        // NFTMarket nft = new NFTMarket(address(myNFT), address(token));

        vm.stopBroadcast();
    }
}
