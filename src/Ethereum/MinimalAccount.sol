// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IAccount} from "lib/account-abstraction/contracts/interfaces/IAccount.sol";
import {PackedUserOperation} from "lib/account-abstraction/contracts/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "lib/account-abstraction/contracts/core/Helpers.sol";
import {IEntryPoint} from "lib/account-abstraction/contracts/interfaces/IEntryPoint.sol";

contract MinimalAccount is IAccount, Ownable {
    /*/////////////////////////////////////////////////////////////
                    Errors
    ////////////////////////////////////////////////////////////*/
    error MinimalAccount__NotFromEntryPoint();
    error MinimalAccount__NotFromEntryPointOrOwner();
    error MinimalAccount__CallFailed(bytes);

    /*/////////////////////////////////////////////////////////////
                    State Variables
    ///////////////////////////////////////////////////////////*/

    IEntryPoint private immutable i_entryPoint;

    /*/////////////////////////////////////////////////////////////
                    Modifiers
    ///////////////////////////////////////////////////////////*/
    modifier requireFromEntryPoint() {
        if (msg.sender != address(i_entryPoint)) {
            revert MinimalAccount__NotFromEntryPoint();
        }
        _;
    }

    modifier requireFromEntryPointOrOwner() {
        if (msg.sender != address(i_entryPoint) && msg.sender != owner()) {
            revert MinimalAccount__NotFromEntryPointOrOwner();
        }
        _;
    }

    /*/////////////////////////////////////////////////////////////
                   Functions
    ///////////////////////////////////////////////////////////*/

    constructor(address entryPoint) Ownable(msg.sender) {
        i_entryPoint = IEntryPoint(entryPoint);
    }

    receive() external payable {}
    /*/////////////////////////////////////////////////////////////
                    External Functions
    ////////////////////////////////////////////////////////////*/

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

    function execute(address dest, uint256 value, bytes calldata functionData) external requireFromEntryPoint {
        (bool success, bytes memory result) = dest.call{value: value}(functionData);
        if (!success) {
            revert MinimalAccount__CallFailed(result);
        }
    }

    /*/////////////////////////////////////////////////////////////
                    Internal Functions
    ////////////////////////////////////////////////////////////*/

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

    /*//////////////////////////////////////////////////////////////
                        Getter Functions
    ///////////////////////////////////////////////////////////////*/
    function getEntryPoint() external view returns (address) {
        return address(i_entryPoint);
    }
}

