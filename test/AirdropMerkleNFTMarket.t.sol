// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/src/Test.sol";

import { AirdropMerkleNFTMarket } from "../src/Week4/AirdropMerkleNFTMarket.sol";
import { MyERC2612 } from "../src/Week3/MyERC2612.sol"; // token with permit function
import { MyERC721 } from "../src/Week2/MyERC721.sol"; // NFT
import { SigUtils } from "./SigUtils.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AirdropMerkleNFTMarketTest is Test {
    MyERC2612 erc2612;
    MyERC721 erc721;
    AirdropMerkleNFTMarket airdropMerkleNFTMarket;
    address alice;
    uint256 alicePk;
    SigUtils internal sigUtils;

    bytes32[] proof = new bytes32[](2);

    function setUp() public {
        erc2612 = new MyERC2612();
        erc721 = new MyERC721();
        (alice, alicePk) = makeAddrAndKey("alice");
        console2.log(alice); // 0x328809Bc894f92807417D2dAD6b7C998c1aFdac6
        sigUtils = new SigUtils(erc2612.DOMAIN_SEPARATOR());
        bytes32 rootHash = 0x487fd3a2cd9f8f73530ef127a60e89497487b844e4a1ef198eb2122d4880a42d;
        airdropMerkleNFTMarket = new AirdropMerkleNFTMarket(address(erc2612), address(erc721), rootHash);

        // alice proof
        proof[0] = 0x72155ab19f64defdca605292f85d05e62580c41852b1bff9f02bd9cf4c4ac1ee;
        proof[1] = 0x037d886f1d839a1bda18c96e2ac6cba9ce99cec681a08013dbf642ba00da30ab;
    }

    function testPermitPrepay() public {
        SigUtils.Permit memory permitResult = SigUtils.Permit({
            owner: alice,
            spender: address(airdropMerkleNFTMarket),
            value: 1e10,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });
        bytes32 digest = sigUtils.getTypedDataHash(permitResult);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, digest);

        vm.startPrank(alice);
        erc2612.mint(alice, 1e10);

        airdropMerkleNFTMarket.permitPrePay(permitResult.value, permitResult.deadline, v, r, s);

        vm.stopPrank();
    }

    function testClaimNFT() public {
        vm.prank(alice);
        airdropMerkleNFTMarket.claimNFT(proof);
    }

    function testMultiCall() public {
        vm.startPrank(alice);
        SigUtils.Permit memory permitResult = SigUtils.Permit({
            owner: alice,
            spender: address(airdropMerkleNFTMarket),
            value: 1e10,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });
        bytes32 digest = sigUtils.getTypedDataHash(permitResult);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, digest);

        erc2612.mint(alice, 1e10);

        bytes[] memory data = new bytes[](2); //一定要初始化数组的长度，否则会报错
        data[0] = abi.encodeWithSelector(airdropMerkleNFTMarket.claimNFT.selector, proof);
        data[1] = abi.encodeWithSelector(
            airdropMerkleNFTMarket.permitPrePay.selector, permitResult.value, permitResult.deadline, v, r, s
        );

        airdropMerkleNFTMarket.multicall(data);
        vm.stopPrank();
    }
}
