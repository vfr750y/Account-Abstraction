# About

Account abstraction - anything can be made into a wallet.
EIP-4337, activated in March 2023, uses EntryPoint.sol as a standardized contract to handle UserOperations (a pseudo-transaction type)
EIP-7702 (May 2025) operates without requiring external infrastructure like bundlers or a separate mempool, unlike EIP-4337. It's purpose is to simplify account abstraction for Externally owned addresses only.
While EIP-7702 reduces reliance on EIP-4337 for certain account abstraction use cases, EntryPoint.sol and EIP-4337 remain valuable for scenarios requiring more complex or persistent smart contract wallet functionality.
EIP-7702 only enables temporary delegation of Externally Owned Address (EOA) behavior to smart contract logic for a single transaction.
EIP-7702 and EIP-4337 are designed to coexist. EIP-7702 handles native, EOA-based AA, while EIP-4337 supports full smart contract wallets and complex transaction flows. The Ethereum Foundation and EIP authors (e.g., Vitalik Buterin) have emphasized that EIP-7702 enhances, rather than replaces, EIP-4337.
Signature Aggregators addon allows definition a group of signatures to be added (multi-sig).
Pay master addon allows for sponsorship of the alt-memepool gas fees. Without a paymaster, the on-chain contract associated with the EIP-4337 account will need to have enough ETH to pay for the gas.
In zkSync the alt-memepool capability is coded into the a standard zksync node. Use transaction type 113. This makes the zkSync nodes capable of natively supporting account abstraction. (Every single account in zkSync uses the DefaultAccount smart contract ).

# Project Overview


1. Create a basic Account Abstraction on Ethereum.
    https://eips.ethereum.org/EIPS/eip-4337
    The user operation contains the full data that needs to be sent to the Alt-memepool.
    The EntryPoint interface is a packed version of the UserOperation (packedUserOperation) that is passed to the on-chain EntryPoint contract, account and Paymaster.
    The EntryPoint.sol contract contains a function called handleOps which takes a PackedUserOperation array and a payable address
    The PackedUserOperation.sol interface contains a struct called PackedUserOperation containing the parameters for the PackedUserOperation array:
    - sender	address	 
    - nonce	uint256	 
    - initCode	bytes	concatenation of factory address and factoryData (or empty), or EIP-7702 data
    - callData	bytes	 
    - accountGasLimits	bytes32	concatenation of verificationGasLimit (16 bytes) and callGasLimit (16 bytes)
    - preVerificationGas	uint256	 
    - gasFees	bytes32	concatenation of maxPriorityFeePerGas (16 bytes) and maxFeePerGas (16 bytes)
    - paymasterAndData	bytes	concatenation of paymaster fields (or empty)
    - signature	bytes
    The Account Contract Interface (IAccount) is the core interface for an account.
   It contains the validateUserOp function which returns a uint256
   If the UserOperation is valid the user Account contract will allow the Alt-memepool to send the transaction on behalf of the account.

2. Create a basic Account Abstraction on zkSync
3. Deploy and send a userOp / transaction through each of them.
