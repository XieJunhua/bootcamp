// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import { Test, console2 } from "forge-std/src/Test.sol";
import { TokenBank, BaseERC20 } from "../src/Week2/BaseERC20.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    // address myErc20;
    address alice;
    BaseERC20 private my20;

    function setUp() public virtual {
        alice = makeAddr("alice");
        // myErc20 = makeAddr("myErc20");
        my20 = new BaseERC20(alice);
        tokenBank = new TokenBank(address(my20));
    }

    function testFailDeposit() public {
        vm.startPrank(alice);

        // my20.approve(address(tokenBank), 10_000);

        tokenBank.deposit(10_000);

        assertEq(tokenBank.getAccounts(), 10_000);

        vm.stopPrank();
    }

    function test_deposit() public {
        deposit(alice, 10_000);
    }

    function test_withdraw() public {
        deposit(alice, 10_000);
        vm.startPrank(alice);

        tokenBank.withdraw(10_000);
        assertEq(tokenBank.getAccounts(), 0);
    }

    function test_tokenReceive() public {
        vm.startPrank(alice);
        my20.transferWithFallback(address(tokenBank), 10_000, "test");

        assertEq(tokenBank.getAccounts(), 10_000);
        vm.stopPrank();
    }

    function deposit(address who, uint256 value) private {
        vm.startPrank(who);

        my20.approve(address(tokenBank), value);

        tokenBank.deposit(value);

        assertEq(tokenBank.getAccounts(), value);

        vm.stopPrank();
    }
}
