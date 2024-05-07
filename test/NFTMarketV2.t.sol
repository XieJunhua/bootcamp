// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import { Test, console2 } from "forge-std/src/Test.sol";
import { NFTMarketV2 } from "../src/Week4/NFTMarketV2.sol";
import { BaseERC20, TokenAccessError, ListNFT } from "../src/Week4/NFTMarketV1.sol";
import { MyERC721 } from "../src/Week2/MyERC721.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract NFTMarketV2Test is Test {
    using MessageHashUtils for bytes32;

    NFTMarketV2 nftMarket;
    address alice;
    uint256 alicePk;
    BaseERC20 private my20;

    address bob = makeAddr("bob");
    address tom = makeAddr("tom");
    MyERC721 internal my721;

    function setUp() public {
        my20 = new BaseERC20(alice);
        my721 = new MyERC721();

        nftMarket = new NFTMarketV2();
        nftMarket.initialize(address(my721), address(my20));
        (alice, alicePk) = makeAddrAndKey("alice");
        console2.log(alicePk);

        my721.mint(alice, "https://ipfs.io/ipfs/QmY5WwRyZm7P6cT9y4uNcHr5eVJvXsQkLX9VZgVn5h7uZ");
        my721.mint(tom, "https://ipfs.io/ipfs/QmY5WwRyZm7P6cT9y4uNcHr5eVJvXsQkLX9VZgVn5h7uZ");
    }

    function testList() public {
        vm.startPrank(alice);
        uint256 price = 1e6;
        uint256 tokenId = 0;
        bytes32 hash = keccak256(abi.encodePacked(tokenId + price)).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, hash);

        nftMarket.listWithSignature(tokenId, price, v, r, s);

        my721.setApprovalForAll(address(nftMarket), true);
        assertEq(my721.isApprovedForAll(alice, address(nftMarket)), true);
        vm.stopPrank();
    }

    function testSignature() public {
        vm.startPrank(0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC);
        uint256 price = 1000;
        uint256 tokenId = 3;
        bytes32 hash = keccak256(abi.encodePacked(tokenId + price)).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a, hash);
        // console.log(v);

        // console2.log(v);
        // console2.log(abi.encodePacked(r, s, v));
        // console2.log(string(abi.encodePacked(s)));
        // nftMarket.listWithSignature(tokenId, price, v, r, s);

        // my721.setApprovalForAll(address(nftMarket), true);
        // assertEq(my721.isApprovedForAll(alice, address(nftMarket)), true);
        // vm.stopPrank();
    }
}
