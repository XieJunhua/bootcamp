// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.25;

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract TestVerify {
    function recover(bytes memory _data, bytes memory _signature) public pure returns (address) {
        bytes32 hash = MessageHashUtils.toEthSignedMessageHash(_data);
        return ECDSA.recover(hash, _signature);
    }
}
