// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/src/Test.sol";

import { RNTIDO } from "../src/Week4/RNTIDO.sol";
import { RNT } from "../src/Week4/RNT.sol";

contract RNTIDOTest is Test {
    RNTIDO rntido;
    RNT rnt;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address tokenHolder = makeAddr("tokenHolder");
    uint256 PRICE;

    function setUp() public {
        rnt = new RNT();

        rntido = new RNTIDO(address(rnt), tokenHolder);
        rnt.mint(tokenHolder, 1e10);
        PRICE = rntido.PRICE();
        // rnt.approve(rnt, rntido, 100_000);
    }

    function test_presale() public {
        presale(alice, 1 ether);
    }

    function testClaim() public {
        presale(alice, 5 ether);
        presale(bob, 5 ether);
        vm.prank(tokenHolder);
        rnt.approve(address(rntido), 1e10);
        console2.log(rnt.allowance(tokenHolder, address(rntido)));

        vm.prank(bob);
        vm.warp(block.timestamp + 10 days);
        rntido.claim();
        assertEq(rnt.balanceOf(bob), 5 ether / PRICE);

        vm.prank(alice);
        rntido.claim();
        assertEq(rnt.balanceOf(alice), 5 ether / PRICE);
    }

    function testFund() public {
        presale(alice, 5 ether);
        vm.prank(alice);
        vm.warp(block.timestamp + 10 days);
        vm.deal(alice, 0);
        rntido.refund();
        assertEq(alice.balance, 5 ether);
        // assertEq(rntido.RNT_balances(alice), 5 ether / PRICE);
    }

    function presale(address who, uint256 cast) private {
        vm.deal(who, cast);
        vm.prank(who);
        rntido.presale{ value: cast }(cast / PRICE);
        assertEq(rntido.RNT_balances(who), cast / PRICE);
    }
}
