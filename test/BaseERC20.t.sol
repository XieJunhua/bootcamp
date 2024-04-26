// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/src/Test.sol";
import { BaseERC20 } from "../src/Week2/BaseERC20.sol";

contract BaseERC20Test is Test {
    BaseERC20 private my20;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address tom = makeAddr("tom");

    function setUp() public virtual {
        my20 = new BaseERC20(alice);
    }

    function test_transfer() public {
        vm.startPrank(alice);
        assertEq(my20.balanceOf(alice), 100_000_000_000_000_000_000_000_000);
        assertEq(my20.balanceOf(bob), 0);
        my20.transfer(bob, 10_000);
        assertEq(my20.balanceOf(alice), 100_000_000_000_000_000_000_000_000 - 10_000);
        assertEq(my20.balanceOf(bob), 10_000);
        vm.stopPrank();
    }

    function test_approve() public {
        vm.startPrank(alice);
        assertEq(my20.allowance(alice, tom), 0);
        my20.approve(tom, 10_000);
        assertEq(my20.allowance(alice, tom), 10_000);
        vm.stopPrank();
    }

    function test_transferFrom() public {
        vm.prank(alice);
        my20.approve(tom, 10_000);
        assertEq(my20.allowance(alice, tom), 10_000);
        assertEq(my20.balanceOf(alice), 100_000_000_000_000_000_000_000_000);
        assertEq(my20.balanceOf(bob), 0);
        vm.prank(tom);
        my20.transferFrom(alice, bob, 10_000);
        assertEq(my20.allowance(alice, tom), 0);
        assertEq(my20.balanceOf(bob), 10_000);
    }
}
