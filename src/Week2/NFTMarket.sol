// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { BaseERC20 } from "./BaseERC20.sol";

error AccessError(address _address);

contract NFTMarket is IERC721Receiver {
    struct NFT {
        uint256 price;
        address ownerAddress;
    }

    mapping(uint256 tokenId => NFT nft) private products;
    address private nftAddress;
    address private tokenAddress;

    event Log(address, address, uint256, bytes);

    constructor(address _nftAddress, address _tokenAddress) {
        nftAddress = _nftAddress;
        tokenAddress = _tokenAddress;
    }

    function list(uint256 _tokenId, uint256 price) public returns (bool) {
        bool owner = IERC721(nftAddress).ownerOf(_tokenId) == msg.sender;
        if (!owner) {
            revert AccessError(nftAddress);
        }
        // require(owner, "you are not owner");

        // NFT memory n;
        // n.price = price;
        // n.ownerAddress = msg.sender;

        // products[_tokenId] = n;
        products[_tokenId] = NFT({ price: price, ownerAddress: msg.sender });

        return true;
    }

    function checkList(uint256 _tokenId) public view returns (NFT memory) {
        return products[_tokenId];
    }

    // buyNFT need to approve to this contract
    function buyNFT(uint256 _tokenId) public returns (bool) {
        NFT memory n = products[_tokenId];
        uint256 price = n.price;
        // uint256 balace = BaseERC20(tokenAddress).balanceOf(msg.sender);

        // require(balace >= price, "you don't have enough money");

        BaseERC20(tokenAddress).transferFrom(msg.sender, n.ownerAddress, price);
        // require(transferSuccess, "transfer from BaseERC20 failure");

        IERC721(nftAddress).safeTransferFrom(n.ownerAddress, msg.sender, _tokenId);

        NFT memory n1 = products[_tokenId];
        n1.ownerAddress = msg.sender;

        products[_tokenId] = n1;

        return true;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    )
        external
        returns (bytes4)
    {
        emit Log(operator, from, tokenId, data);

        return IERC721Receiver.onERC721Received.selector ^ this.buyNFT.selector;
    }
}
