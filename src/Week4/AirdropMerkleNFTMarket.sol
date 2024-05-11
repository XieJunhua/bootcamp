// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { MyERC2612 } from "../Week3/MyERC2612.sol"; // token with permit function
import { MyERC721 } from "../Week2/MyERC721.sol"; // NFT
import { Multicall } from "@openzeppelin/contracts/utils/Multicall.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract AirdropMerkleNFTMarket is Multicall {
    MyERC2612 public immutable myERC2612;
    MyERC721 public immutable myERC721;
    bytes32 immutable rootHash;

    uint256 constant PRICE = 1e10;

    constructor(address _myERC2612, address _myERC721, bytes32 _rootHash) {
        myERC2612 = MyERC2612(_myERC2612);
        myERC721 = MyERC721(_myERC721);
        rootHash = _rootHash;
    }

    function permitPrePay(uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external {
        myERC2612.permit(msg.sender, address(this), value, deadline, v, r, s);
        myERC2612.transferFrom(msg.sender, address(this), value);
    }

    function claimNFT(bytes32[] calldata proof) public {
        bytes32 node = keccak256(abi.encodePacked(msg.sender));
        require(MerkleProof.verify(proof, rootHash, node), "Invalid proof");

        myERC721.mint(msg.sender, "https://ipfs.io/ipfs/QmY5WwRyZm7P6cT9y4uNcHr5eVJvXsQkLX9VZgVn5h7uZ/0");
    }

    // function claim(
    //     address owner,
    //     address spender,
    //     uint256 value,
    //     uint256 deadline,
    //     uint8 v,
    //     bytes32 r,
    //     bytes32 s,
    //     bytes32[] calldata proof
    // )
    //     external
    // {
    //     bytes[] memory data;
    //     data[0] = abi.encodeWithSelector(this.permitPrePay.selector, owner, spender, value, deadline, v, r, s);
    //     data[1] = ;
    //     // multicall(data);
    // }

    // ...
}
