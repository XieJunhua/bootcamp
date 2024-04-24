// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { ERC721URIStorage, ERC721 } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyERC721 is ERC721URIStorage {
    constructor() ERC721("JunhuaToken", "JHT") { }

    uint256 private _nextTOkenId;

    function mint(address _address, string memory tokenURI) public returns (uint256) {
        uint256 tokenId = _nextTOkenId++;
        _mint(_address, tokenId);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }
}
