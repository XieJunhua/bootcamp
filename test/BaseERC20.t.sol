// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import { Test, console } from "forge-std/Test.sol";
import { Test, console2 } from "forge-std/src/Test.sol";
import { BaseERC20 } from "../src/Week2/BaseERC20.sol";

contract BaseERC20Test is Test {
    BaseERC20 private my20;
    // address player1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address tom = makeAddr("tom");
    // address player2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    // address player3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    function setUp() public virtual {
        // Instantiate the contract-under-test.
        my20 = new BaseERC20(alice);
    }

    function test_transfer() public {
        // before transfer
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
        // before transfer
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

    function test_BalanceOf() public view {
        // uint256 result = my20.balanceOf(player1);
        // assertEq(result, 100_000_000_000_000_000_000_000_000);
        // console2.log(result);
    }
}
