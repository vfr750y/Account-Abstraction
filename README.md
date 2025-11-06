// Account abstraction - anything can be made into a wallet.
// EIP-4337, activated in March 2023, uses EntryPoint.sol as a standardized contract to handle UserOperations (a pseudo-transaction type)
// EIP-7702 (May 2025) operates without requiring external infrastructure like bundlers or a separate mempool, unlike EIP-4337
// While EIP-7702 reduces reliance on EIP-4337 for certain account abstraction use cases, EntryPoint.sol and EIP-4337 remain valuable for scenarios requiring more complex or persistent smart contract wallet functionality.
// EIP-7702 only enables temporary delegation of Externally Owned Address (EOA) behavior to smart contract logic for a single transaction.
// EIP-7702 and EIP-4337 are designed to coexist. EIP-7702 handles native, EOA-based AA, while EIP-4337 supports full smart contract wallets and complex transaction flows. The Ethereum Foundation and EIP authors (e.g., Vitalik Buterin) have emphasized that EIP-7702 enhances, rather than replaces, EIP-4337.