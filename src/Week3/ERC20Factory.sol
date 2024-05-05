// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import { MyERC20 } from "./MyERC20.sol";

event SendETH(bool, bytes);

contract ERC20Factory {
    address targetAddress;

    uint256 price;

    struct ProjectHolder {
        uint256 perMint;
        address managerAddress;
        uint256 price;
        uint256 totalSupply;
    }

    mapping(address => ProjectHolder) tokenMappings;

    constructor(address _target) {
        targetAddress = _target;
    }

    function deployInscription(
        string memory symbol,
        uint256 totalSupply,
        uint256 perMint,
        uint256 _price
    )
        public
        returns (address)
    {
        address clone = createClone(targetAddress);
        MyERC20(clone).initialize("meme", symbol, totalSupply);
        tokenMappings[clone] =
            ProjectHolder({ perMint: perMint, managerAddress: msg.sender, price: _price, totalSupply: totalSupply });

        return clone;
    }

    function mintInscription(address tokenAddr) public payable {
        uint256 received = msg.value;
        require(received >= tokenMappings[tokenAddr].price);
        ProjectHolder memory projectHolder = tokenMappings[tokenAddr];
        (bool sent, bytes memory data) = projectHolder.managerAddress.call{ value: projectHolder.price / 2 }("");
        emit SendETH(sent, data);
        MyERC20(tokenAddr).transfer(msg.sender, projectHolder.perMint);
    }

    function init(string memory symbol, uint256 totalSupply) public returns (address) {
        address clone = createClone(targetAddress);
        MyERC20(clone).initialize("meme", symbol, totalSupply);
        return clone;
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
