// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/src/Test.sol";
import { SimpleEIP712 } from "../../src/examples/SimpleEIP712.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract EIP172Test is Test {
    using MessageHashUtils for bytes32;

    SimpleEIP712 simpleEIP712;
    address alice;
    uint256 alicePk;

    function setUp() public {
        simpleEIP712 = new SimpleEIP712();
        (alice, alicePk) = makeAddrAndKey("alice");
    }

    function testVerify() public {
        // bytes memory signature,
        // address signer,
        // address mailTo,
        // string memory mailContents

        vm.startPrank(alice);
        uint256 price = 1e6;
        uint256 tokenId = 0;
        bytes32 hash = keccak256(abi.encodePacked(tokenId + price)).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, hash);

        simpleEIP712.verify(tokenId, price, v, r, s);

        vm.stopPrank();
    }
}
