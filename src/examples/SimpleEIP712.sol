// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SimpleEIP712 is EIP712 {
    constructor() EIP712("test", "1.0") { }

    struct Mail {
        address to;
        string contents;
    }

    function verify(
        bytes memory signature,
        address signer,
        address mailTo,
        string memory mailContents
    )
        external
        view
        returns (address)
    {
        bytes32 digest = _hashTypedDataV4(
            keccak256(abi.encode(keccak256("Mail(address to,string contents)"), mailTo, keccak256(bytes(mailContents))))
        );
        address recoveredSigner = ECDSA.recover(digest, signature);
        require(recoveredSigner == signer, "signers not equal");
        return recoveredSigner;
    }
}
