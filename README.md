# GAUwallet v2

Cross-platform wallet for GAUGECASH protocol built with Flutter.

## Architecture

- **Frontend**: Flutter (Android, iOS, Web, macOS, Linux)
- **Backend**: Serverless API on Vercel (Python)
- **Blockchain**: Polygon mainnet (EVM-compatible)
- **Meta-transactions**: RelayerV4 contract for gasless transactions

## Features

- ✅ Send/receive GAU and USDT tokens
- ✅ Gasless transactions (pay fees with tokens instead of POL)
- ✅ Token swaps via Uniswap V3
- ✅ Real-time price feeds via Chainlink oracles
- ✅ QR code scanning for addresses
- ✅ Transaction history
- ✅ Multi-currency support (GAU, USDT, POL)

## Configuration

### Network: Polygon Mainnet

**RPC Endpoint:**
- Infura: `https://polygon-mainnet.infura.io/v3/7248d1d106eb4597836b43b5378af021`

**Meta-Transaction Backend:**
- URL: `https://metatx.vercel.app`
- RelayerV4: `0xA7E2f9aF0023CF4558Baac747Dd01179297dDE8D`

**Token Addresses:**
- GAU: `0xcBccdf5c97aac84f7536B255B5D35ED57AD363A3`
- USDT: `0xc2132D05D31c914a87C6611C10748AEb04B58e8F`
- Uniswap V3 Router: `0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45`

## Development

### Prerequisites

- Flutter SDK 3.24.0+
- Dart SDK
- Android Studio (for Android builds)
- Xcode (for iOS/macOS builds)

### Setup

```bash
# Install dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Build for web
flutter build web --release

# Run tests
flutter test
```

### Project Structure

```
lib/
├── conf.dart                    # Configuration (RPC, addresses, etc.)
├── models/                      # Data models
├── providers/                   # State management (Riverpod)
├── repository/                  # Blockchain interaction layer
│   ├── coins/                   # Token-specific logic (GAU, USDT)
│   ├── meta_tx.dart             # Meta-transaction functions
│   ├── rpc.dart                 # RPC client
│   └── simple_swap.dart         # Swap logic
├── screens/                     # UI screens
│   ├── currency/                # Send/receive screens
│   └── home/                    # Home, swap screens
├── components/                  # Reusable UI components
└── styling.dart                 # Theme and styles
```

## Deployment

### Web Deployment (Vercel)

```bash
# Build for production
flutter build web --release --web-renderer canvaskit

# Deploy to Vercel (from project root)
vercel --prod
```

**Current deployments:**
- Preview: `https://gauwallet-preview.vercel.app`
- Production: `https://app.gaugecash.com`

### Android Deployment (Google Play)

See `.github/workflows/ci-cd.yml` for automated build pipeline.

## Meta-Transactions

The wallet supports gasless transactions where users pay fees in GAU or USDT tokens instead of POL (native gas token).

**How it works:**
1. User signs a meta-transaction (ERC-20 `permit` + transfer)
2. Backend relayer submits transaction on-chain
3. RelayerV4 contract executes transfer and deducts 0.5% fee from token amount
4. User never needs POL in wallet

**Supported operations:**
- GAU transfers (gasless)
- USDT transfers (gasless)
- GAU ↔ USDT swaps (gasless)

## Security

- ✅ Private keys encrypted with AES-256 (user password-derived key)
- ✅ No private keys sent to backend
- ✅ Meta-transactions use EIP-2612 permits (signed off-chain)
- ✅ Nonce management prevents replay attacks
- ✅ All RPC calls use authenticated Infura endpoint

## License

Private repository - All rights reserved.

## Contact

- Organization: [gaugecash](https://github.com/gaugecash)
- Website: [www.gaugecash.com](https://www.gaugecash.com)
