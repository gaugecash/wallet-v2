# Architecture

## Overview

GAUwallet is a Flutter application that enables users to:
- Send/receive GAU tokens
- Send/receive USDT tokens
- Swap between GAU and USDT
- Use gasless transactions (meta-transactions)

## System Components

### 1. GAUwallet (This Repo)
- **Technology:** Flutter/Dart
- **Platforms:** Web, Android, iOS
- **Role:** User interface, transaction signing

### 2. Meta-Transaction Backend
- **Repo:** gaugecash/meta_tx
- **URL:** https://metatx.vercel.app
- **Role:** Relays signed transactions to blockchain, pays gas

### 3. Smart Contracts (Polygon)
- **RelayerV4:** Executes meta-transactions
- **GAU Token:** ERC-20 with permit (gasless approve)
- **USDT Token:** Standard ERC-20

## Data Flow

### Standard Transaction (User Pays Gas)
User signs tx → Wallet sends to Polygon RPC → Blockchain executes
User pays POL for gas

### Gasless Transaction (Meta-Transaction)
User signs permit → Wallet sends to metatx.vercel.app → Backend pays gas → Blockchain executes
Backend deducts fee from token amount

## Key Files

| File | Purpose |
|------|---------|
| lib/conf.dart | All configuration values |
| lib/repository/meta_tx.dart | Meta-transaction logic |
| lib/repository/coins/gau.dart | GAU token operations |
| lib/repository/coins/usd.dart | USDT token operations |
| lib/repository/rpc.dart | RPC connection handling |
| lib/screens/currency/_send.dart | Send screen with gasless toggle |
| lib/screens/home/swap_gau.dart | Token swap screen |

## Security

- Private keys never leave user's device
- Keys encrypted with AES-256-GCM
- Meta-transactions use EIP-2612 permits (signed messages, not private keys)
