// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import { Test, console2 } from "forge-std/src/Test.sol";
// import { NFTMarket, BaseERC20, TokenAccessError, ListNFT, InvalidAddressError } from "../src/Week2/NFTMarket.sol";
// import { MyERC2612 } from "../src/Week3/MyERC2612.sol";
// import { TokenBank, BaseERC20 } from "../src/Week2/BaseERC20.sol";
import { MyERC20 } from "../src/Week3/MyERC20.sol";
import { ERC20Factory } from "../src/Week3/ERC20Factory.sol";
import { IERC20Errors } from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
// import "filename";

// import { SigUtils } from "./SigUtils.sol";
// import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
// import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract ERC20FactoryTest is Test {
    ERC20Factory erc20Factory;
    MyERC20 myERC20;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address address1 = makeAddr("address1");
    address address2 = makeAddr("address2");

    function setUp() public {
        myERC20 = new MyERC20();
        erc20Factory = new ERC20Factory(address(myERC20));
    }

    function test_init() public {
        // newErc20.init("hh", "hh", 1e18);
        address clone = erc20Factory.init("hh", 1e18);
        MyERC20 newErc20 = MyERC20(clone);

        assertEq(newErc20.symbol(), "hh");
        assertEq(newErc20.decimals(), 18);
    }

    function test_deployInscription() public {
        // token "hh"
        vm.prank(alice);
        address tokenAddress = erc20Factory.deployInscription("hh", 1e18, 1e5, 1e5);
        assertEq(MyERC20(tokenAddress).balanceOf(address(erc20Factory)), 1e18);
        mintFromFactory(bob, tokenAddress, alice, 1e5, 1e5);

        // token "gg"
        vm.prank(address1);
        address anotherTokenAddress = erc20Factory.deployInscription("gg", 1e18, 1e6, 1e6);
        assertEq(MyERC20(anotherTokenAddress).balanceOf(address(erc20Factory)), 1e18);
        mintFromFactory(address2, anotherTokenAddress, address1, 1e6, 1e6);
    }

    function testrevertOverSupply() public {
        vm.prank(alice);
        address tokenAddress = erc20Factory.deployInscription("hh", 1e5, 1e5, 1e5);
        assertEq(MyERC20(tokenAddress).balanceOf(address(erc20Factory)), 1e5);
        mintFromFactory(bob, tokenAddress, alice, 1e5, 1e5);

        vm.expectRevert(
            abi.encodeWithSelector(IERC20Errors.ERC20InsufficientBalance.selector, address(erc20Factory), 0, 1e5)
        );

        vm.deal(address1, 1 ether);
        vm.prank(address1);
        // mint over the supply will revert ERC20InsufficientBalance
        erc20Factory.mintInscription{ value: 1e5 }(tokenAddress);
    }

    function mintFromFactory(
        address _who,
        address tokenAddress,
        address tokenManager,
        uint256 price,
        uint256 perMint
    )
        public
    {
        uint256 balanceAliceBeforeMint = _who.balance;
        uint256 balanceFactoryBeforeMint = address(erc20Factory).balance;
        vm.deal(_who, 1 ether);
        vm.prank(_who);
        // _who mint once, want to get {price} token
        erc20Factory.mintInscription{ value: price }(tokenAddress);

        assertEq(MyERC20(tokenAddress).balanceOf(address(_who)), perMint);
        assertEq(tokenManager.balance, balanceAliceBeforeMint + price / 2); // token manager alice get price / 2 wei
        assertEq(address(erc20Factory).balance, balanceFactoryBeforeMint + price / 2); // factory get price / 2 wei as
            // fee
    }

    function createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone, 0x14), targetBytes)
            mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            result := create(0, clone, 0x37)
        }
    }
}
