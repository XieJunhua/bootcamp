// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import { Test, console2 } from "forge-std/src/Test.sol";
import { NFTMarket, BaseERC20, TokenAccessError, ListNFT } from "../src/Week2/NFTMarket.sol";
import { MyERC721 } from "../src/Week2/MyERC721.sol";

contract NFTMarketTest is Test {
    NFTMarket nftMarket;
    address alice = makeAddr("alice");
    BaseERC20 private my20;

    address bob = makeAddr("bob");
    address tom = makeAddr("tom");
    MyERC721 internal my721;

    function setUp() public {
        my20 = new BaseERC20(alice);
        my721 = new MyERC721();

        nftMarket = new NFTMarket(address(my721), address(my20));

        my721.mint(bob, "https://ipfs.io/ipfs/QmY5WwRyZm7P6cT9y4uNcHr5eVJvXsQkLX9VZgVn5h7uZ");
        my721.mint(tom, "https://ipfs.io/ipfs/QmY5WwRyZm7P6cT9y4uNcHr5eVJvXsQkLX9VZgVn5h7uZ");
    }

    function test_list() public {
        list(bob, 0, 100);
    }

    function test_buyNFT() public {
        list(bob, 0, 100);
        vm.prank(bob);
        my721.approve(address(nftMarket), 0);
        vm.startPrank(alice);
        my20.approve(address(nftMarket), 100);
        assertEq(my20.balanceOf(bob), 0);
        //
        nftMarket.buyNFT(0);
        assertEq(my20.balanceOf(bob), 100);
        assertEq(my721.ownerOf(0), alice);
        assertEq(nftMarket.checkList(0).ownerAddress, alice);
        vm.stopPrank();
    }

    function test_tokenReceive() public {
        list(bob, 0, 100);
        vm.startPrank(alice);
        uint256 i = 0;
        my20.transferWithFallback(address(nftMarket), 100, abi.encodePacked(i));

        assertEq(my20.balanceOf(bob), 100);
        assertEq(nftMarket.checkList(0).ownerAddress, alice);
        vm.stopPrank();
    }

    function test_expectError() public {
        // vm.expectRevert(bytes32(keccak256("AccessError(address)")));
        vm.startPrank(address(alice));
        vm.expectRevert(abi.encodeWithSelector(TokenAccessError.selector, alice, 0));

        nftMarket.list(0, 200);
        vm.stopPrank();
    }

    function test_expectEvent() public {
        vm.expectEmit(true, true, true, true);
        emit ListNFT(address(my721), 0, bob, 100);
        list(bob, 0, 100);
    }

    function list(address who, uint256 _tokenId, uint256 price) public {
        vm.startPrank(who);
        assertEq(my721.ownerOf(_tokenId), who);
        nftMarket.list(_tokenId, price);
        assertEq(nftMarket.checkList(_tokenId).price, price);
        assertEq(nftMarket.checkList(_tokenId).ownerAddress, who);
        vm.stopPrank();
    }
}
