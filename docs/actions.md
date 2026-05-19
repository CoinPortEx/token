Excellent. Given your confirmation, let's move to the actionable blueprint.

## **CoinPort Loyalty Token: Implementation Blueprint**

Based on your requirements, here's the **recommended technical architecture**:

> **Live deployment (2026-05-19):** CPP is published at proxy address `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` on **five public EVM chains**: [Ethereum mainnet](https://etherscan.io/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) (canonical, since 2026-05-18), [BNB Smart Chain](https://bscscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5), [Arbitrum One](https://arbiscan.io/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5), [Polygon](https://polygonscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5), and [Avalanche C-Chain](https://avascan.info/blockchain/c/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) — the latter three went live on 2026-05-19. The blueprint below remains the design-intent record — three divergences from what shipped: (i) custody is Model B / custodial (no per-user balances, no `batchMint`); (ii) the closed-loop transfer guard is disabled on the live contracts (all chains); and (iii) the deployment is now multi-chain, with each chain operated as an independent sibling rather than the original Ethereum-only blueprint, motivated by ecosystem-integration reach and consistent token tracking via a single canonical address across all five chains. See `whitepaper.md` for the current public framing.

### **Core Specification: "CoinPort Loyalty Points" (CPP)**
**Token Type:** ERC-20 with critical modifications
**Blockchain:** Ethereum L1 mainnet
**Key Feature:** **Semi-fungible with restricted transfers**

### **Smart Contract Critical Features**
1. **Transfer Restrictions**
   ```solidity
   // Only allow transfers between whitelisted addresses
   mapping(address => bool) public isWhitelisted;
   // Or alternatively, implement a transfer blocker with exemptions
   bool public transfersEnabled = false; // Default false
   function enableTransfers(bool _enable) external onlyOwner {}
   ```

2. **Admin Controls** (via `AccessControl`)
   * Minting rights restricted to loyalty engine server
   * Burning rights for redemption
   * Pause functionality for emergencies
   * Address freezing for compliance

3. **Optional Governance Path** (ERC-20Votes extension)
   * Can be unlocked later via upgrade
   * Allows community voting on fee discounts, reward pools

### **Business Logic Layer Architecture**
```
User Actions → CoinPort Backend → Smart Contract Calls
      ↓              ↓                  ↓
• Trade rewards  • Validate    • Mint CPP to user
• Fee discounts  • Calculate   • Burn CPP on redemption
• Referral bonus • Compliance  • Log events
• Staking rewards check
```

### **Deployment Phases**

**Phase 1: MVP (Closed System)**
- Deploy restricted ERC-20 on Ethereum L1 mainnet
- Points earned via trading volume, holding balances
- Points redeemable only for: Trading fee discounts (10-30%), Priority support, Early feature access
- **No external transfers enabled**

**Phase 2: Expansion**
- Add ERC-20Permit for gasless approvals
- Introduce time-locked staking rewards
- Enable peer-to-peer transfers **only between verified CoinPort users**

**Phase 3: Ecosystem (If desired)**
- Convert accumulated CPP to governance token via vesting schedule
- Launch separate DeFi pool for CPP stakers
- Add NFT achievement badges (ERC-1155 companion)

### **Critical Implementation Details**

1. **Minting Schedule**
   - Implement daily/weekly volume-based calculations off-chain
   - Batch mint transactions to save gas
   - Consider Merkle tree claims for efficient distribution

2. **Compliance Safeguards**
   ```solidity
   // Required for regulatory alignment
   function addToWhitelist(address[] calldata accounts) external onlyComplianceOfficer {}
   function forceTransfer(address from, address to, uint256 amount) external onlyOwner {} // For account recovery
   ```

3. **Upgrade Strategy**
   - Use transparent proxy pattern (OpenZeppelin)
   - Maintain upgradeability for first 12-18 months
   - Plan for eventual immutable deployment after features stabilize

### **Risk Mitigation Checklist**
- [ ] Third-party audit before mainnet deployment
- [ ] Multi-sig wallet for admin functions (3-of-5 recommended)
- [ ] Rate limiting on minting functions
- [ ] Comprehensive event logging for all privileged actions
- [ ] Circuit breaker to pause all functions if abnormal activity detected
- [ ] Testnet deployment with simulated user load

### **Expected Costs (Ethereum L1 mainnet)**
- Development & Audit: $50k–$100k (one-time)
- Mainnet deployment (impl + transparent proxy): ~$150–$400 in gas, depending on prevailing gwei
- Monthly operations under Model B (one batch mint + occasional burn/freeze tx): ~$300–$1,500 in gas, varies with gas price
- **Total Year 1:** ~$60k–$130k (gas line item is small relative to audit)

> Gas budgeting assumes ETH ~$3,500 and 25–60 gwei base fee. At sustained high gas (>100 gwei), monthly ops can exceed $3k — the loyalty engine should consider deferring non-urgent mints when fees spike.

### **Next Immediate Actions**
1. **Document exact earning mechanics** (formulas, caps, schedules)
2. **Define redemption catalog** with clear point valuations
3. **Mainnet operational planning**: gas-price monitoring, fee-spike contingency, deployer wallet funding strategy
4. **Engage legal counsel** on whether CPP constitutes a security in your jurisdictions

---

**Bottom Line:** Build a **permissioned ERC-20 on Ethereum L1 mainnet** with transfer restrictions, admin controls, and clear upgrade path. Under the Model B custodial design, on-chain transaction volume is low (one daily batch mint, occasional burns), so L1 gas costs remain manageable while inheriting the strongest security guarantees and broadest exchange/wallet compatibility.

