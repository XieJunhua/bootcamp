// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/src/Test.sol";

import { Bank } from "../src/Week4/Bank.sol";

contract BankTest is Test {
    Bank bank;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address charlie = makeAddr("charlie");
    address dave = makeAddr("dave");
    address eve = makeAddr("eve");
    address fred = makeAddr("fred");
    address ginny = makeAddr("ginny");
    address harriet = makeAddr("harriet");
    address ileana = makeAddr("ileana");
    address jessie = makeAddr("jessie");
    address kate = makeAddr("kate");
    address linda = makeAddr("linda");
    address minnie = makeAddr("minnie");
    address nancy = makeAddr("nancy");

    function setUp() public virtual {
        bank = new Bank();
    }

    function testBankDeposit() public {
        // vm.pauseGasMetering();
        // _deposit(alice, 10);
        // _deposit(bob, 20);
        _deposit(charlie, 30);
        _deposit(dave, 4);
        _deposit(eve, 5);
        // _deposit(fred, 6);
        // _deposit(ginny, 7);
        // _deposit(harriet, 8);
        // _deposit(ileana, 9);
        _deposit(jessie, 15);
        _deposit(kate, 111);
        // _deposit(linda, 12);
        // _deposit(minnie, 13);
        _deposit(nancy, 13);
        _deposit(dave, 10);

        bank.nodes(bank.head());
        // assertEq(deposit, charlie);

        // assertEq(next, bob);
        // assertEq(value, 30);

        (address next1, uint256 value1, address deposit1) = bank.nodes(jessie);
        // assertEq(deposit, 15);
        assertEq(next1, dave);
        assertEq(value1, 15);
    }

    function _deposit(address who, uint256 amount) public {
        vm.deal(who, amount);
        vm.prank(who);
        bank.deposit{ value: amount }();
    }

    // function checkNode(address who)  returns () {

    // }
}
