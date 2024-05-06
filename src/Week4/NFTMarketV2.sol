// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { NFTMarketV1, MessageHashUtils, ECDSA, InvalidAddressError, ListNFT } from "./NFTMarketV1.sol";

contract NFTMarketV2 is NFTMarketV1 {
    function upgrade() public {
        version = "v2";
    }

    function listWithSignature(uint256 _tokenId, uint256 price, uint8 v, bytes32 r, bytes32 s) public {
        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(_tokenId + price)));
        address recover = ECDSA.recover(hash, abi.encodePacked(r, s, v));
        if (recover != msg.sender) {
            revert InvalidAddressError(msg.sender);
        }
        products[_tokenId] = NFT({ price: price, ownerAddress: msg.sender });
        emit ListNFT(nftAddress, _tokenId, msg.sender, price);
    }
}
