// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/src/Test.sol";

import { RNT } from "../src/Week4/RNT.sol";
import { EsRNT } from "../src/Week4/EsRNT.sol";
import { RNTStake } from "../src/Week4/RNTStake.sol";

contract RNTStakeTest is Test {
    RNTStake rntStake;
    RNT rnt;
    EsRNT esRNT;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        rnt = new RNT();
        esRNT = new EsRNT();
        rntStake = new RNTStake(address(rnt), address(esRNT));
    }

    function testDeposit() public {
        deposit(alice, 1e4);
    }

    function testclaim() public {
        deposit(alice, 10_000);
        vm.warp(block.timestamp + 5 days);
        vm.prank(alice);
        rntStake.claim();

        assertEq(50_000, esRNT.balanceOf(alice));
        (uint256 lastRewardTime, uint256 depositAmount, uint256 rewardAmount) = rntStake.deposits(alice);

        assertEq(lastRewardTime, block.timestamp);
        assertEq(depositAmount, 10_000);
        assertEq(rewardAmount, 0);
    }

    function testWithdraw() public {
        deposit(alice, 10_000);
        vm.warp(block.timestamp + 5 days);
        vm.prank(alice);
        rntStake.withdraw(5000);

        (uint256 lastRewardTime, uint256 depositAmount, uint256 rewardAmount) = rntStake.deposits(alice);
        assertEq(depositAmount, 5000);
        assertEq(lastRewardTime, block.timestamp);
        assertEq(rewardAmount, 50_000);
    }

    function testBurn() public {
        deposit(alice, 10_000);
        vm.warp(block.timestamp + 15 days);
        vm.startPrank(alice);
        rntStake.claim();

        // vm.warp(block.timestamp + 15 days);
        // rntStake.burn();

        // assertEq(75_000, esRNT.balanceOf(alice));
        // assertEq(75_000, rnt.balanceOf(alice));

        vm.warp(block.timestamp + 315 days);
        rntStake.burn();

        assertEq(0, esRNT.balanceOf(alice));
        assertEq(150_000, rnt.balanceOf(alice));
        vm.stopPrank();
    }

    function deposit(address who, uint256 amount) private {
        rnt.mint(who, amount);
        // vm.prank(who);
        vm.startPrank(who);
        rnt.approve(address(rntStake), amount);
        rntStake.deposit(amount);
        // Staking  s = ;
        (uint256 lastRewardTime, uint256 depositAmount, uint256 rewardAmount) = rntStake.deposits(who);
        assertEq(depositAmount, amount);
        assertEq(lastRewardTime, block.timestamp);
        assertEq(rewardAmount, 0);
        vm.stopPrank();
    }
}
