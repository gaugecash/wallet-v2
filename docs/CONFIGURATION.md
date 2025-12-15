# Configuration Reference

All configuration values are in lib/conf.dart.

## RPC Configuration

const List<String> mainRPC = [
  'https://polygon-mainnet.infura.io/v3/7248d1d106eb4597836b43b5378af021',
];

**Purpose:** Polygon blockchain RPC endpoint

**Notes:**
- Using Infura for reliability
- Single endpoint (no fallbacks currently)
- API key is not secret (read-only access)

**If Changing:** Update the Infura project ID if rotating credentials.

---

## Backend Configuration

const String mainMetaTxServer = 'https://metatx.vercel.app';

**Purpose:** Backend server for gasless meta-transactions

**Related:** gaugecash/meta_tx repository

**If Changing:** Only change if backend URL changes. Wallet and backend must match.

---

## Contract Addresses

const String mainMetaTxSpender = '0xA7E2f9aF0023CF4558Baac747Dd01179297dDE8D';  // RelayerV4
const String mainGauAddress = '0xcBccdf5c97aac84f7536B255B5D35ED57AD363A3';      // GAU Token
const String mainUsdtAddress = '0xc2132D05D31c914a87C6611C10748AEb04B58e8F';     // USDT Token

**Purpose:** Immutable contract addresses on Polygon mainnet

**If Changing:** Never change unless deploying entirely new contracts.

---

## Gasless Default Setting

**File:** lib/screens/currency/_send.dart

final useGauForFee = useState(false);

**Purpose:** Default state of gasless toggle

**Values:**
- false = User pays gas in POL (default)
- true = Gasless enabled by default

**Current Setting:** false - Users opt-in to gasless

---

## API Endpoints

The wallet calls these endpoints on mainMetaTxServer:

| Endpoint | Purpose |
|----------|---------|
| /api/transferGau | Gasless GAU transfer |
| /api/GAU_USDT_METATX | Gasless GAU to USDT swap |
| /api/USDT_GAU_METATX | Gasless USDT transfer |
| /api/SWAP_USDT_GAU_METATX | Gasless USDT to GAU swap |
