// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import { Test, console2 } from "forge-std/src/Test.sol";
import { NFTMarket, BaseERC20, TokenAccessError, ListNFT, InvalidAddressError } from "../src/Week2/NFTMarket.sol";
import { MyERC2612 } from "../src/Week3/MyERC2612.sol";
import { TokenBank, BaseERC20 } from "../src/Week2/BaseERC20.sol";
import { MyERC721 } from "../src/Week2/MyERC721.sol";

import { SigUtils } from "./SigUtils.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract MyERC2612Test is Test {
    using MessageHashUtils for bytes32;

    SigUtils internal sigUtils;

    uint256 internal ownerPrivateKey;
    uint256 internal spenderPrivateKey;

    address internal owner;
    address internal spender;
    MyERC2612 myERC2612;
    TokenBank tokenBank;
    NFTMarket nftMarket;
    MyERC721 internal my721; // nft
    address _address = 0x518948e6dAe180bBA4Fdb0F819481d44C317A861;

    address bob = makeAddr("bob");
    address alice;
    uint256 alicePk;

    mapping(address => bytes) signs;

    function setUp() public {
        (alice, alicePk) = makeAddrAndKey("alice");
        myERC2612 = new MyERC2612();
        sigUtils = new SigUtils(myERC2612.DOMAIN_SEPARATOR());
        tokenBank = new TokenBank(address(myERC2612));

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        owner = vm.addr(ownerPrivateKey);
        spender = vm.addr(spenderPrivateKey);

        my721 = new MyERC721();
        nftMarket = new NFTMarket(address(my721), address(myERC2612));

        myERC2612.mint(owner, 1e18);
        myERC2612.mint(spender, 1e18);
        my721.mint(bob, "https://ipfs.io/ipfs/QmY5WwRyZm7P6cT9y4uNcHr5eVJvXsQkLX9VZgVn5h7uZ");
        my721.mint(alice, "https://ipfs.io/ipfs/QmY5WwRyZm7P6cT9y4uNcHr5eVJvXsQkLX9VZgVn5h7uZ");

        console2.log(alice);
        signWho(owner);
    }

    /**
     *  add _who to the whitelist
     * @param _who address who need to be signed
     */
    function signWho(address _who) private {
        bytes32 hash = keccak256(abi.encodePacked(_who)).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(alicePk, hash);
        bytes memory signature = abi.encodePacked(r, s, v);
        signs[_who] = signature;
    }

    function testRecover() public {
        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(owner)));
        // bytes32 hash = keccak256(abi.encodePacked(owner)).toEthSignedMessageHash();
        // bytes32 hash = keccak256(abi.encodePacked(owner));
        address recover = ECDSA.recover(hash, signs[owner]);
        assertEq(alice, recover);
        console2.log(recover);
    }

    function testDeposit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: spender,
            value: 1e18,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        myERC2612.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);

        assertEq(myERC2612.allowance(owner, spender), 1e18);
        assertEq(myERC2612.nonces(owner), 1);
    }

    function testPermitDeposit() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: owner,
            spender: address(tokenBank),
            value: 1e18,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });

        bytes32 digest = sigUtils.getTypedDataHash(permit);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);
        console2.log();
        vm.startPrank(owner);
        console2.log(msg.sender);
        console2.log(owner);
        tokenBank.permitDeposit(permit.value, permit.deadline, v, r, s);
        assertEq(tokenBank.getAccounts(), 1e18);
        vm.stopPrank();
    }

    function testPermitBuy() public {
        // 生成转账的签名
        (SigUtils.Permit memory permit, uint8 v, bytes32 r, bytes32 s) =
            getPermit(owner, ownerPrivateKey, address(nftMarket));

        list(bob, 0, 1e18);

        vm.prank(bob);
        // 上架用户对该NFT进行授权
        my721.approve(address(nftMarket), 0);
        vm.prank(owner);
        nftMarket.permitBuy(signs[owner], 0, permit.value, permit.deadline, v, r, s);

        assertEq(myERC2612.balanceOf(bob), 1e18);
        assertEq(my721.ownerOf(0), owner);
        assertEq(nftMarket.checkList(0).ownerAddress, owner);
    }

    function test_expectError() public {
        (SigUtils.Permit memory permit, uint8 v, bytes32 r, bytes32 s) =
            getPermit(spender, spenderPrivateKey, address(nftMarket));

        list(bob, 0, 1e18);

        vm.prank(bob);
        my721.approve(address(nftMarket), 0);
        vm.startPrank(spender);
        vm.expectRevert(abi.encodeWithSelector(InvalidAddressError.selector, spender));

        // 尝试用owner这个人的hash去购买NFT
        nftMarket.permitBuy(signs[owner], 0, permit.value, permit.deadline, v, r, s);
        vm.stopPrank();
        // InvalidAddressError e = vm.expectRevert();
        // assertEq(myERC2612.balanceOf(bob), 1e18);
        // assertEq(my721.ownerOf(0), owner);
        // assertEq(nftMarket.checkList(0).ownerAddress, owner);
    }

    function getPermit(
        address _who,
        uint256 _pk,
        address _spender
    )
        public
        view
        returns (SigUtils.Permit memory permitResult, uint8 v, bytes32 r, bytes32 s)
    {
        permitResult = SigUtils.Permit({
            owner: _who,
            spender: _spender,
            value: 1e18,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });
        bytes32 digest = sigUtils.getTypedDataHash(permitResult);
        (v, r, s) = vm.sign(_pk, digest);
    }

    function list(address who, uint256 _tokenId, uint256 price) public {
        vm.startPrank(who);
        assertEq(my721.ownerOf(_tokenId), who);
        nftMarket.list(_tokenId, price);
        assertEq(nftMarket.checkList(_tokenId).price, price);
        assertEq(nftMarket.checkList(_tokenId).ownerAddress, who);
        vm.stopPrank();
    }

    function mint() private {
        myERC2612.mint(_address, 100_000);
        myERC2612.mint(alice, 100_000);
        // myERC2612.mint(bob, 100000);
    }
}
