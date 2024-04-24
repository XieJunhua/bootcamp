// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import { Test, console } from "forge-std/Test.sol";
import { Test, console2 } from "forge-std/src/Test.sol";
import { BaseERC20 } from "../src/Week2/BaseERC20.sol";

contract BaseERC20Test is Test {
    BaseERC20 private my20;
    address player1 = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address player2 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address player3 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;

    function setUp() public virtual {
        // Instantiate the contract-under-test.
        my20 = new BaseERC20(player1);
    }

    function testTransfer() public view {
        // my20.transfer(player2, 10_000);
        // assertEq(my20.balanceOf(player1), 100_000_000_000_000_000_000_000_000 - 10_000);
        // assertEq(my20.balanceOf(player2), 10_000);
        uint256 result = my20.balanceOf(player1);
        assertEq(result, 100_000_000_000_000_000_000_000_000);
    }

    function testBalanceOf() public view {
        uint256 result = my20.balanceOf(player1);
        assertEq(result, 100_000_000_000_000_000_000_000_000);
        // console2.log(result);
    }
}
