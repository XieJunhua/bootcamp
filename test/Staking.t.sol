// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/src/Test.sol";

import "../src/Week5/Staking.sol";

contract StakingTest is Test {
    Staking staking;
    KK kk;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    function setUp() public {
        kk = new KK();
        staking = new Staking(address(kk));
    }

    function testStake() public {
        stake(alice, 1 ether);
        assertEq(staking.balanceOf(alice), 1 ether);
    }

    function testUnstake() public {
        stake(alice, 1 ether);
        vm.prank(alice);
        staking.unstake(1 ether);
        assertEq(staking.balanceOf(alice), 0);
    }

    function testClaim() public {
        stake(alice, 1 ether);
        stake(bob, 1 ether);
        vm.roll(block.number + 1);
        stake(alice, 3 ether);
        vm.roll(block.number + 1);
        // console2.log("alice earned", staking.earned(alice));
        // stake(alice, 3 ether);
        // console2.log("bob earned", staking.earned(bob));
        assertEq(staking.earned(alice), (5 + 8) * 1e18);
        assertEq(staking.earned(bob), (5 + 2) * 1e18);
        // console2.log("alice earned", staking.earned(alice));
    }

    function stake(address _who, uint256 _amount) public {
        deal(_who, _amount);
        vm.prank(_who);
        staking.stake{ value: _amount }();
    }
}
