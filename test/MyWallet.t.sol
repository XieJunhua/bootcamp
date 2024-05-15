// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { console2 } from "forge-std/src/Test.sol";

import "./BaseTest.t.sol";

import "../src/Week5/MyWallet.sol";

contract MyWalletTest is BaseTest {
    MyWallet wallet;

    function setUp() public {
        vm.prank(alice);
        wallet = new MyWallet("alice");
    }

    function testtransferOwernship() public {
        vm.prank(alice);
        wallet.transferOwernship(bob);
        assertEq(wallet.owner(), bob);
    }
}
