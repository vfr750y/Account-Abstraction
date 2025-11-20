
# Minimal Account - ERC-4337 & zkSync Native Account Abstraction Implementation

A minimal, secure, and well-tested implementation of **ERC-4337 compatible smart contract accounts** (for EVM chains) and **native Account Abstraction on zkSync Era**, built with **Foundry**.

This project demonstrates two production-ready minimal account implementations:

- `MinimalAccount.sol` → Standard ERC-4337 account (EIP-4337) for Ethereum, Sepolia, Arbitrum, etc.
- `ZkMinimalAccount.sol` → Native AA smart account for **zkSync Era** (using type 113 transactions)

Both accounts are owned by an EOA and support signature validation via `eth_sign` (EIP-191), enabling gasless or sponsored transactions via bundlers and paymasters.

---

### Features

- ERC-4337 Compatible Smart Contract Wallet (`MinimalAccount`)
- Native zkSync Era Account Abstraction Support (`ZkMinimalAccount`)
- Owner-based signature validation (simple & secure)
- Full test suite using Foundry
- Multi-chain deployment scripts (Mainnet, Sepolia, Anvil, Arbitrum)
- Mock token interaction examples (USDC approve/mint)
- Clean separation of concerns with `HelperConfig`
- Uses OpenZeppelin and official Account Abstraction contracts

---

### Project Structure

```
src/
├── Ethereum/MinimalAccount.sol          # ERC-4337 Minimal Account
├── zksync/ZkMinimalAccount.sol          # zkSync Native AA Account
script/
├── DeployMinimal.s.sol                  # Deployment script
├── SendPackedUserOp.s.sol               # Sends a UserOperation via EntryPoint
├── HelperConfig.s.sol                   # Chain-specific config (EntryPoint, accounts)
test/
├── MinimalAccountTest.t.sol             # Foundry tests for EVM chains
└── zkMinimalAccountTest.t.sol           # Tests for zkSync (requires --zk-sync flag)
```

---

### Prerequisites

- [Foundry](https://github.com/foundry-rs/foundry) (`forge`, `cast`, `anvil`)
- Node.js (for `forge install` dependencies)

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

---

### Installation

```bash
git clone https://github.com/yourusername/minimal-account-aa.git
cd minimal-account-aa
forge install
```

Dependencies included via submodules:
- `account-abstraction` (ERC-4337 contracts)
- `foundry-era-contracts` (zkSync system contracts)
- `foundry-devops` (deployment tools)
- OpenZeppelin Contracts

---

### Testing

#### Standard EVM Chains (Anvil, Sepolia, etc.)

```bash
forge test
```

#### zkSync Era Tests (Local Node Required)

Start a zkSync local node first (in Docker):

```bash
# In a separate terminal
docker run --rm -it -p 3311:3311 -p 3060:3060 matterlabs/local-node
```

Then run zkSync-specific tests:

```bash
forge test --zk-sync -vv
```

> Note: Use `--system-mode=true` if testing full bootloader interaction.

---

### Deployment

#### 1. Deploy on Anvil (Local)

```bash
# Start anvil
anvil

# Deploy in another terminal
forge script script/DeployMinimal.s.sol:DeployMinimal --rpc-url http://localhost:8545 --broadcast
```

#### 2. Deploy on Sepolia / Mainnet

Update `BURNER_WALLET` in `HelperConfig.s.sol` to your funded address.

```bash
forge script script/DeployMinimal.s.sol:DeployMinimal \
  --rpc-url $SEPOLIA_RPC_URL \
  --account "deployer" \
  --broadcast \
  --verify \
  --etherscan-api-key $ETHERSCAN_KEY
```

---

### Send a User Operation (ERC-4337)

After deploying the `MinimalAccount`, run:

```bash
forge script script/SendPackedUserOp.s.sol:SendPackedUserOp \
  --rpc-url http://localhost:8545 \
  --broadcast
```

This script:
- Signs a `PackedUserOperation`
- Submits it via `EntryPoint.handleOps()`
- Approves 1e18 USDC to a random address (as an example action)

Works locally on Anvil and on real ERC-4337 chains (Sepolia, etc.)

---

### Key Design Decisions

| Feature                        | Implementation Detail                                                                 |
|-------------------------------|---------------------------------------------------------------------------------------|
| Signature Validation          | Owner signs `toEthSignedMessageHash(userOpHash)` → standard `eth_sign` compatible     |
| Access Control                | Only EntryPoint or Owner can call `execute()`                                         |
| Prefund Payment               | Automatically pays missing funds to EntryPoint during validation                     |
| zkSync Native AA              | Uses `validateTransaction`, increments nonce via `NonceHolder`, pays bootloader       |
| Gas Limits                    | Hardcoded safe defaults (can be upgraded later)                                       |

---

### Security Considerations

- Uses battle-tested OpenZeppelin `Ownable` and `ECDSA`
- Reverts on failed calls with data (`CallFailed(bytes)`)
- Proper access control via modifiers
- No external calls in signature validation (view function)
- Supports account recovery by transferring ownership

---

### Resources

- ERC-4337 Spec: https://eips.ethereum.org/EIPS/eip-4337
- zkSync Account Abstraction Docs: https://era.zksync.io/docs/
- EntryPoint Address (v0.7): `0x0000000071727De22E5E9d8BAf0edAc6f37da032`
- Foundry Book: https://book.getfoundry.sh/

---

### License

MIT License

---
