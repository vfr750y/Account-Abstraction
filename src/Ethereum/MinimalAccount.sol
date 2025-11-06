// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";

contract MinimalAccount is IAccount, Ownable {
    constructor() Ownable(msg.sender) {}

    // Signature validation criteria can be anything. In this simple example, as signature is valid if it is the account owner. This allows the smart contract wallet holder to transfer to a different owner without revealing the private key.The owner of the contract needs to be the signer of the PackedUserOperation calldata.

    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData)
    {
        // In IAccount.sol validationData is the packaged validationdata structure. The first 20 bytes of which denote a 0 for a valid signature and 1 to mark a signature failure.
        // The validation of the nonce uniqueness is managed by the entrypoint.sol contract
        validationData = _validateSignature(userOp, userOpHash);
        // missingAccountFunds denotes how much the transaction costs and the amount payable to whoever sent the transaction (i.e. the entrypoint contract)
        _payPrefund(missingAccountFunds);
    }

    // EIP-191 version of the signed hash needs to be converted into a standard keccak256 hash
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        view
        returns (uint256 validationData)
    {
        bytes32 ethSignedMessageHash = MessageHashUtils.toEthSignedMessageHash(userOpHash);
        address signer = ECDSA.recover(ethSignedMessageHash, userOp.signature); // this will return who did the signing
        if (signer != owner()) {
            return SIG_VALIDATION_FAILED;
        }
        return SIG_VALIDATION_SUCCESS;
    }

    function _payPrefund(uint256 missingAccountFunds) internal {
        if (missingAccountFunds != 0) {
            (bool success,) = payable(msg.sender).call{value: missingAccountFunds, gas: type(uint256).max}("");
            (success);
        }
    }
}

