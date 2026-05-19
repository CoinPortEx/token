Perfect. Let's build the **Earning Mechanics Document**—the core business logic that will drive your token's value and user engagement.

---

## **COINPORT LOYALTY POINTS (CPP) - EARNING MECHANICS SPECIFICATION v1.0**

### **1. Core Philosophy**
- **Transparent & Predictable:** Users should understand exactly how to earn points
- **Aligned with Exchange Health:** Reward behaviors that benefit CoinPort (liquidity, volume, retention)
- **Progressive Engagement:** Simple entry, deep rewards for loyal users
- **Sustainable Issuance:** Controlled inflation with built-in deflationary burns

### **2. Earning Channels**

#### **A. Trading Volume Rewards (Primary Driver)**
```
CPP Earned = (Daily Volume in USD) × (Multiplier Tier) × (Asset Boost)
```
- **Tiered Multipliers:**
  - Tier 1 (<$10k daily volume): 0.5 CPP per $1k volume
  - Tier 2 ($10k-$100k): 1.0 CPP per $1k volume  
  - Tier 3 ($100k-$1M): 1.5 CPP per $1k volume
  - Tier 4 (>$1M): 2.0 CPP per $1k volume + 0.5x referral bonus on sub-accounts

- **Asset Boosts:**
  - CoinPort Launchpad Tokens: 2.0x multiplier
  - Major Pairs (BTC/ETH/USDT): 1.0x multiplier
  - Low Volume Altcoins: 1.5x multiplier (to incentivize liquidity)

- **Calculation:** Daily snapshots at 00:00 UTC, distributed next day at 02:00 UTC

#### **B. Holding Balances (Staking-Like)**
```
Daily CPP = (Average Daily Balance in USDT equivalent) × (APR/365)
```
- **Tiered APR:**
  - 30-day lock: 8% APR
  - 90-day lock: 12% APR  
  - 180-day lock: 18% APR
  - 365-day lock: 25% APR + NFT Badge (ERC-1155)

- **Qualifying Assets:** BTC, ETH, USDT, USDC, CPPT (if governance token exists)
- **Minimum:** $100 equivalent
- **Distribution:** Real-time accrual, claimable anytime (encourages regular engagement)

#### **C. Activity & Engagement**
- **Daily Login Streak:** 
  - Day 7: 10 CPP
  - Day 30: 50 CPP + "Consistent" NFT badge
  - Day 100: 200 CPP + "Dedicated" NFT badge
- **Complete Profile Verification:** 50 CPP (one-time)
- **Mobile App Download & Notification Enable:** 25 CPP
- **First Trade of the Month:** 15 CPP
- **Provide Feedback/Bug Report:** 10-100 CPP (manual review)

#### **D. Referral Program**
```
Referral CPP = (Referee's 30-day Volume) × 0.001 × (Your Tier Multiplier)
```
- **Base Reward:** 10% of referee's trading fee paid (in CPP equivalent)
- **Growth Bonus:** 5 CPP for every new referee who verifies account
- **Ladder Bonus:** Earn 2.5% of sub-referrals (2 levels deep)
- **Monthly Top Referrer:** Bonus 500-5000 CPP based on ranking

#### **E. Special Events**
- **Trading Competitions:** Top 100 by volume get 100-10,000 CPP
- **Predictions Tournaments:** CPP prizes for accurate market predictions
- **AMA Participation:** 5-20 CPP for asking questions/voting
- **Beta Feature Testing:** 50-200 CPP for feedback

### **3. Anti-Gaming Safeguards**
```javascript
// Pseudo-validation logic
function isValidTradeForPoints(trade) {
  return (
    trade.amount >= $10 &&                  // Minimum trade size
    trade.spread < 2% &&                    // Not wash trading
    !isSelfTrade(trade) &&                  // No matching orders
    trade.holdTime > 1minute &&            // Not high-frequency gaming
    trade.user.ipRegion != highRiskRegion   // Geo-compliance
  );
}
```
- **Wash Trading Detection:** Flag and exclude coordinated volume
- **Cool-down Periods:** Maximum 8 claim events per user per day
- **Velocity Limits:** No more than 10,000 CPP earned per user per day
- **Manual Review Threshold:** Any account earning >50,000 CPP/month gets audit

### **4. Deflationary Mechanics (Burning)**
**Points are destroyed when:**
- Redeeming for fee discounts (1 CPP = $0.01 fee reduction)
- Purchasing NFT badges or avatars
- Entering trading competitions (entry fee)
- Converting to future governance token (at 100:1 ratio)
- Account inactivity >24 months (5% monthly decay)

### **5. Supply Schedule**
```
Year 1: 100M CPP total cap (per chain)
Year 2: +25M (125M total, per chain)
Year 3: +15M (140M total, per chain)
Maximum: 200M CPP (reached Year 7, per chain)
```
- **Initial Distribution:** 5M CPP for launch promotions, per chain
- **Monthly Minting Cap:** 2M CPP per chain
- **Emergency Stop:** Minting can be paused per chain if inflation on that chain exceeds 5% monthly
- **Multi-chain note:** CPP is deployed independently on five chains — Ethereum (canonical), BNB Smart Chain, Arbitrum One, Polygon, and Avalanche C-Chain (all live as of 2026-05-19). The figures above apply **per chain**. Program-wide on-chain issuance ceiling is therefore the per-chain cap × number of supported chains (currently up to **1B CPP** across the five target chains). The multi-chain set was chosen to give CPP a footprint inside several distinct cryptocurrency ecosystems. See `whitepaper.md` §5.1 for the member-facing framing.

### **6. Redemption Catalog (Value Anchor)**
| **Reward** | **CPP Cost** | **Equivalent Value** | **Notes** |
|------------|--------------|---------------------|-----------|
| Trading Rebate — 10% Fee Discount (24h) | 500 | $5 | Most popular |
| Trading Rebate — 30% Fee Discount (1h) | 1,000 | $30 | For large trades |
| Free Airdrop Allocation | 500–5,000 | $5–$50 value | Allocation in CoinPort-listed airdrop events |
| Priority Support Ticket | 200 | $20 | Skip the queue |
| API Rate Limit Boost | 1,000/month | $50/month | For developers |
| Custom Alert Triggers | 300/month | $15/month | Advanced trading |
| Launchpad Allocation | 5,000-50,000 | $50-$500 value | Whitelist spots |
| Physical Merchandise | Varies | Cost + 20% | Hoodies, hardware wallets |
| Charity Donation Match | Any amount | 2x match | Brand alignment |

### **7. Technical Implementation Flow**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Actions  │ →  │  Backend Logic  │ →  │  Contract Calls  │
│   • Trade       │    │   • Validation   │    │   • mint()       │
│   • Stake       │    │   • Calculation  │    │   • transfer()   │
│   • Refer       │    │   • Anti-gaming  │    │   • event emit   │
│   • Login       │    │   • Queue        │    │                  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ↑                      ↑                       ↑
    Frontend UI           Database (Ledger)      Five EVM chains
                                              (Ethereum, BSC, Arbitrum,
                                                Polygon, Avalanche)
```

**Batch Processing Design:**
```solidity
// Gas-efficient batch minting
function batchMint(
    address[] calldata recipients,
    uint256[] calldata amounts
) external onlyMinter {
    require(recipients.length == amounts.length);
    for (uint i = 0; i < recipients.length; i++) {
        _mint(recipients[i], amounts[i]);
    }
}
```

### **8. Key Performance Indicators (KPIs)**
- **Target:** 30% of active users earn CPP daily
- **Target:** 25% redemption rate within 90 days of earning
- **Max inflation:** 2% monthly supply growth
- **Goal:** CPP-driven users trade 3x more volume

### **9. Legal & Compliance Notes**
- CPP are **not securities** – cannot be converted to fiat directly
- Terms & Conditions must state: "Points have no cash value, are non-transferable"
- Regional restrictions may apply (exclude prohibited jurisdictions)
- KYC required for any user earning >10,000 CPP/month

### **10. Launch Timeline**
**Week 1-2:** Core earning (trading volume, holding)
**Week 3-4:** Add referral program  
**Month 2:** Introduce staking locks
**Month 3:** Launch NFT badges & redemption marketplace

---

## **NEXT ACTION ITEMS:**

1. **Finalize these numbers** with your trading data (average user volume, retention rates)
2. **Design the dashboard UI** showing: CPP balance, earning rate, redemption options
3. **Build the anti-gaming system** before launch
4. **Create the redemption marketplace** smart contract
5. **Legal review** of all point mechanics and terms

---

**Would you like me to:** 
1. **Create the smart contract skeleton** based on these mechanics?
2. **Design the database schema** for tracking off-chain calculations?
3. **Outline the marketing rollout plan** for the loyalty program?
