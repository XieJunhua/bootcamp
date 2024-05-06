// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721Receiver } from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import { BaseERC20, TokenRecipient, InvalidAddressError, AmountExceedError } from "../Week2/BaseERC20.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import { MyERC2612 } from "../Week3/MyERC2612.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

error TokenAccessError(address, uint256);

event ListNFT(address nftAddress, uint256 tokenId, address ownerAddress, uint256 price);

contract NFTMarketV1 is IERC721Receiver, TokenRecipient, OwnableUpgradeable, UUPSUpgradeable {
    struct NFT {
        uint256 price;
        address ownerAddress;
    }

    mapping(uint256 tokenId => NFT nft) internal products;
    address internal nftAddress;
    address internal tokenAddress;
    string version;

    event Log(address, address, uint256, bytes);

    address signer = 0x328809Bc894f92807417D2dAD6b7C998c1aFdac6;

    // constructor(address _nftAddress, address _tokenAddress) {
    //     nftAddress = _nftAddress;
    //     tokenAddress = _tokenAddress;
    // }

    function initialize(address _nftAddress, address _tokenAddress) public initializer {
        nftAddress = _nftAddress;
        tokenAddress = _tokenAddress;
        OwnableUpgradeable.__Ownable_init(msg.sender);
        version = "v1";
    }

    function list(uint256 _tokenId, uint256 price) public returns (bool) {
        bool owner = IERC721(nftAddress).ownerOf(_tokenId) == msg.sender;
        if (!owner) {
            revert TokenAccessError(msg.sender, _tokenId);
        }
        products[_tokenId] = NFT({ price: price, ownerAddress: msg.sender });
        emit ListNFT(nftAddress, _tokenId, msg.sender, price);

        return true;
    }

    function checkList(uint256 _tokenId) public view returns (NFT memory) {
        return products[_tokenId];
    }

    // buyNFT need to approve to this contract
    function buyNFT(uint256 _tokenId) public returns (bool) {
        NFT memory n = products[_tokenId];
        uint256 price = n.price;

        BaseERC20(tokenAddress).transferFrom(msg.sender, n.ownerAddress, price);

        IERC721(nftAddress).safeTransferFrom(n.ownerAddress, msg.sender, _tokenId);

        NFT memory n1 = products[_tokenId];
        n1.ownerAddress = msg.sender;

        products[_tokenId] = n1;

        return true;
    }

    function permitBuy(
        bytes memory _signature,
        uint256 _tokenId,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        public
        returns (bool)
    {
        address _address = msg.sender;
        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(keccak256(abi.encodePacked(_address)));

        address recover = ECDSA.recover(hash, _signature);
        if (recover != signer) {
            revert InvalidAddressError(_address);
        }

        NFT memory n = products[_tokenId];
        uint256 price = n.price;

        MyERC2612(tokenAddress).permit(msg.sender, address(this), value, deadline, v, r, s);

        MyERC2612(tokenAddress).transferFrom(msg.sender, n.ownerAddress, price);

        IERC721(nftAddress).safeTransferFrom(n.ownerAddress, msg.sender, _tokenId);

        NFT memory n1 = products[_tokenId];
        n1.ownerAddress = msg.sender;

        products[_tokenId] = n1;

        return true;
    }

    function tokenReceive(address _address, uint256 value, bytes memory extraData) public returns (bool) {
        if (tokenAddress != msg.sender) {
            revert InvalidAddressError(_address);
        }
        uint256 _tokenId = abi.decode(extraData, (uint256));
        NFT memory n1 = products[_tokenId];
        BaseERC20(tokenAddress).transfer(n1.ownerAddress, n1.price);
        if (value < n1.price) {
            revert AmountExceedError(_address);
        }
        delete products[_tokenId];

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

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner { } // solhint-disable-line
}
