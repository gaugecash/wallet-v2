# Meta-Transactions (Gasless)

## What Are Meta-Transactions?

Meta-transactions allow users to send tokens without holding POL for gas fees.

**Normal Transaction:**
- User signs transaction
- User pays gas in POL
- Transaction executes

**Meta-Transaction:**
- User signs a permit (message, not transaction)
- Backend receives permit
- Backend submits transaction and pays gas
- Backend deducts fee from token amount
- User receives tokens minus small fee

---

## How It Works

### Step 1: User Signs Permit
User wants to send 100 GAU
Wallet creates EIP-2612 permit
User signs with private key (never leaves device)

### Step 2: Wallet Sends to Backend
POST https://metatx.vercel.app/api/transferGau
Body: { permit signature, amount, recipient, etc. }

### Step 3: Backend Executes
Backend verifies permit
Backend calls RelayerV4 contract
Backend pays gas in POL
RelayerV4 transfers tokens (minus fee)

### Step 4: Result
Recipient receives: 99.5 GAU (0.5% fee)
User spent: 0 POL
Backend spent: ~0.001 POL (gas)
Backend received: 0.5 GAU (fee)

---

## Components

| Component | Location | Role |
|-----------|----------|------|
| Permit signing | lib/repository/meta_tx.dart | Creates signed permits |
| Backend API | gaugecash/meta_tx | Relays to blockchain |
| RelayerV4 | Polygon: 0xA7E2f9aF0023CF4558Baac747Dd01179297dDE8D | Executes transfers |

---

## Endpoints

| Endpoint | Operation |
|----------|-----------|
| /api/transferGau | GAU transfer |
| /api/GAU_USDT_METATX | GAU to USDT swap |
| /api/USDT_GAU_METATX | USDT transfer |
| /api/SWAP_USDT_GAU_METATX | USDT to GAU swap |

---

## Fee Structure

- **Current fee:** 0.5% of transaction amount
- **Configured in:** RelayerV4 contract (on-chain)
- **Paid to:** Relayer wallet (0x078a92ddC63d350eB3a1f5797a775c6B84F8D2c7)

---

## User Experience

In the wallet UI:
- Toggle "Pay fee in GAU/USDT" appears on send screen
- Default: OFF (user pays POL)
- When ON: Gasless transaction, fee deducted from amount

Setting controlled in: lib/screens/currency/_send.dart
final useGauForFee = useState(false);  // false = off by default

---

## Troubleshooting

**Transaction fails with "insufficient allowance":**
- Permit may have expired (check deadline)
- Nonce mismatch (user sent another tx)

**Backend returns 500:**
- Check backend logs on Vercel
- Check relayer POL balance

**User didn't receive tokens:**
- Check PolygonScan for tx hash
- Verify recipient address
- Check if fee was deducted correctly
