## Authorization-Governed Secure Vault

## Overview

This project implements an authorization-governed on-chain vault that allows controlled withdrawals of pooled funds.
Withdrawals are not executed freely; instead, each withdrawal must be explicitly authorized off-chain and validated on-chain before funds are released.

The system is designed to demonstrate:

- secure smart-contract architecture

- replay-attack prevention

- clear separation of responsibilities

- correct handling of adversarial scenarios

All components run locally using Docker, and the entire system is deployed automatically using docker-compose.

## High-Level Architecture

The system consists of two smart contracts and supporting infrastructure:

User
 │
 │ (withdrawal request)
 ▼
Off-chain Signer
 │
 │ (signed authorization)
 ▼
AuthorizationManager (on-chain)
 │
 │ (verification + replay protection)
 ▼
SecureVault (on-chain)
 │
 │ (fund transfer)
 ▼
Recipient

## Smart Contract Components

1. SecureVault

Responsibilities

- Holds pooled ETH

- Accepts deposits

- Executes withdrawals only after authorization validation

- Emits deposit and withdrawal events

Key Properties

-Does not perform signature validation itself

-Delegates permission checks to AuthorizationManager

-Prevents overdrafts

2. AuthorizationManager

Responsibilities

- Verifies withdrawal authorizations

- Ensures each authorization is used only once

- Prevents replay attacks

- Confirms signature authenticity

Key Properties

- Stores consumed authorization identifiers

- Only the vault contract can consume an authorization

- Authorizations are cryptographically bound to context

Authorization Design

Each withdrawal authorization is bound to the following parameters:

- Vault contract address

- Chain ID

- Recipient address

- Withdrawal amount

- Unique nonce

- Expiry timestamp

These parameters are hashed and signed off-chain by a trusted signer.
On-chain verification ensures that the authorization cannot be reused, cannot be forged, and cannot be replayed on another chain or vault.

## Replay Protection

Replay attacks are prevented by:

- Deriving a unique authorization hash from all contextual parameters

- Recording consumed authorizations on-chain

- Rejecting any attempt to reuse an authorization

Once an authorization is consumed, it is permanently invalid.

## Events

The system emits the following events for transparency and auditing:

- Deposit(address from, uint256 amount)

- Withdrawal(address to, uint256 amount)

## Project Structure

/
├─ contracts/
│  ├─ SecureVault.sol
│  └─ AuthorizationManager.sol
│
├─ scripts/
│  └─ deploy.js
│
├─ tests/
│  └─ system.spec.js
│
├─ docker/
│  ├─ Dockerfile
│  └─ entrypoint.sh
│
├─ docker-compose.yml
└─ README.md

## Running the Project

Prerequisites

- Docker

- Docker Compose

No local blockchain or node installation is required.

## Start the System

docker-compose up --build


This command will:

1. Start a local EVM blockchain

2. Compile all smart contracts

3. Deploy AuthorizationManager

4. Deploy SecureVault

5. Wire the vault to the authorization manager

No manual deployment steps are needed.


## Testing (Optional but Recommended)

If you wish to run tests locally (outside Docker):

npx hardhat test


The test suite verifies:

1. successful authorized withdrawal

2. prevention of replay attacks

3. rejection of invalid authorizations

## Security Considerations

1. Unauthorized withdrawals are rejected

2. Expired authorizations are rejected

3. Replay attacks are prevented on-chain

4. Signature forgery is prevented via ECDSA recovery

5. Chain-specific binding prevents cross-chain replay

## Assumptions

- A single trusted signer issues authorizations

- The vault manages ETH only

- This implementation targets a local development environment

- Gas optimization is not the primary focus

## Known Limitations

- Multi-signer authorization is not implemented

- Authorization revocation is not supported after issuance

- ERC-20 support is not included

## Conclusion

1. This project demonstrates a secure and extensible pattern for authorization-based asset withdrawals on Ethereum.
2. It emphasizes correctness, clarity, and defense against common attack vectors while maintaining clean separation of concerns.