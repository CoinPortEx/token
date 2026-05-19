# CoinPort Loyalty Points (CPP) — White Paper

**Version:** 1.2
**Date:** 2026-05-19
**Issuer:** CoinPort Exchange Pty Ltd
**Networks:** Ethereum mainnet (canonical, chain id 1); BNB Smart Chain (chain id 56); Arbitrum One (chain id 42161); Polygon (chain id 137); Avalanche C-Chain (chain id 43114). All five live as of 2026-05-19.
**Contract address (same on each chain):** `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5`
([Etherscan](https://etherscan.io/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) · [BscScan](https://bscscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) · [Arbiscan](https://arbiscan.io/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) · [PolygonScan](https://polygonscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) · [Avascan](https://avascan.info/blockchain/c/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5))

---

## Important notices

**This is not an offer of securities.** CoinPort Loyalty Points (CPP) are not sold, offered, or distributed in exchange for money or any other consideration. There has been no initial coin offering (ICO), private sale, presale, public sale, IDO, IEO, or fundraising round of any kind, and none is planned. CPP cannot be purchased.

**CPP is not a financial product.** CPP have no guaranteed monetary value, are not redeemable for fiat currency, do not confer ownership, equity, dividend, or voting rights, and are not traded on any secondary market. CPP have been designed specifically to fall outside the definition of "financial product" under the *Corporations Act 2001* (Cth) and outside the scope of speculative crypto-assets described in ASIC INFO 225.

**This document is informational, not legal or financial advice.** Participation in the CPP program is governed by the [Terms & Conditions](./terms.md). Where this document and the T&Cs conflict, the T&Cs prevail.

---

## 1. Executive summary

CoinPort Loyalty Points (CPP) is the closed-loop loyalty reward token operated by CoinPort Exchange, a registered Virtual Asset Service Provider (VASP). CPP is earned by CoinPort members through trading activity and other forms of engagement with the CoinPort platform, and is redeemed within the CoinPort ecosystem for benefits such as free airdrops, trading rebates, priority support, and other member perks.

CPP is an ERC-20 token deployed independently on **five public EVM blockchains**: **Ethereum mainnet** (canonical), **BNB Smart Chain**, **Arbitrum One**, **Polygon**, and **Avalanche C-Chain**. The same contract bytecode and the same contract address are used on each chain — these are sibling deployments, not bridged representations. Ethereum mainnet remains the canonical reference deployment for regulatory, audit, and member-facing purposes; the other four chains exist to give CPP a footprint inside several distinct cryptocurrency ecosystems and to provide lower-cost on-chain interaction for members and integrators in each of those ecosystems. The underlying token contracts are real, public, and verifiable; however, the **program** operates as a closed-loop loyalty scheme: all CPP is custodied by CoinPort on members' behalf, balances are accounted for in CoinPort's unified off-chain member ledger, and redemption is processed exclusively through the CoinPort platform.

CPP does not exist to raise capital. It exists to give CoinPort's loyalty program a transparent, on-chain audit trail of supply and a credible, durable representation of member rewards — without the regulatory, taxation, and consumer-protection risks of issuing a tradeable cryptocurrency.

---

## 2. The problem CPP solves

Exchanges have run loyalty programs for decades using internal database points. Database points have three persistent weaknesses:

1. **Opacity.** Members cannot independently verify the total points issued, the rate of issuance, or that the program operator is treating users fairly.
2. **Volatility of trust.** When a program operator changes terms, devalues points, or ends a program, members have no public record of what they earned and no way to evidence it externally.
3. **No audit surface.** Regulators, auditors, and partners must rely entirely on the operator's internal records.

Putting the loyalty unit on a public blockchain addresses all three: total supply is verifiable, every mint and burn is permanently logged, and the program operator's commitments are observable rather than opaque.

The trade-off is that "putting points on chain" can drift into "issuing a cryptocurrency" — which exposes operators and users to securities regulation, secondary-market formation, speculative trading, and taxation surprises. CPP is designed to capture the transparency benefits while avoiding that drift, through four binding design constraints described below.

---

## 3. Design principles

CPP is bound by four design constraints. Each one is a deliberate choice that constrains the program's behaviour and is reflected in the smart contract, the operational model, the T&Cs, and the compliance framework.

### 3.1 Closed-loop only

CPP exists only inside the CoinPort ecosystem. CPP cannot be sent to external wallets, traded on a secondary market, swapped for other tokens, or used as payment outside CoinPort. The legal basis is the framing in ASIC INFO 225, under which a token's status as a "financial product" turns substantially on whether it trades on secondary markets.

### 3.2 No fiat conversion

CPP cannot be redeemed for cash. The redemption catalog contains only in-program benefits (rebates, airdrop allocations, member services, merchandise). This keeps CPP definitively outside the "currency" and "investment" framings.

### 3.3 Bounded redemption value

The maximum value of CPP redemptions per member is capped at **AUD $1,000 per calendar year** (GST inclusive). This cap is enforced at the application layer at redemption time. It both reinforces the program's loyalty-not-investment posture and bounds CoinPort's reporting obligations under the AML/CTF Act.

### 3.4 No profit expectation

CPP is marketed and operated as a rewards program, not as an investment opportunity. The redemption value is administrative and set by CoinPort; there is no implicit promise of appreciation, no fundraising history, and no market price discovery mechanism. The *Howey*-style "expectation of profit from the efforts of others" test that ASIC also references is structurally unsatisfied.

---

## 4. Program model

### 4.1 Custodial accounting (Model B)

CPP operates under a **custodial model**: on every supported chain, all minted CPP is held on-chain by a CoinPort-controlled hot wallet at address `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256`. Individual member CPP balances are recorded in CoinPort's unified off-chain member ledger, not as per-member on-chain balances. A member's balance is a single logical figure in the member ledger; the underlying on-chain backing is held across the five chains on which CPP is deployed.

This choice has several consequences:

- **Members do not hold private keys to their CPP.** Members interact with CPP exclusively through their CoinPort account.
- **There is no "withdraw to external wallet" path.** This is by design — it is the operational expression of the closed-loop constraint.
- **The on-chain total supply remains a faithful record** of total CPP outstanding across all members.
- **Per-member earning and redemption events are recorded off-chain** in the member ledger; reconciliation between the off-chain ledger and the on-chain total is part of CoinPort's regular internal audit.

This model is conventional for compliant, custodial loyalty programs and is similar to how airline miles, retailer rewards, and exchange points programs operate — with the addition of a public, on-chain supply record.

### 4.2 Earning

CPP is earned only through engagement with the CoinPort platform. There is no purchase path. The current earning channels are:

- **Trading volume** — tiered multipliers based on rolling daily AUD-equivalent volume.
- **Asset-held balances** — APR-equivalent accrual on qualifying held assets, with tiered rates for longer holding commitments.
- **Activity** — login streaks, profile verification, and similar engagement actions.
- **Referrals** — a share of trading-fee-based reward for referred new members.
- **Special events** — competitions, beta testing, and community participation.

Earning rates and caps are published on the CoinPort platform and may change with **30 days' advance notice** to members. Earning is subject to anti-gaming controls (see §6).

### 4.3 KYC-tiered limits

Earning capacity is bound by the member's KYC tier:

| KYC Tier | Verification | Max monthly earning | Max balance |
|---|---|---|---|
| Basic | Email + phone | 100 CPP | 1,000 CPP |
| Standard | Government photo ID | 10,000 CPP | 100,000 CPP |
| Enhanced | Source-of-wealth documentation | Unlimited | Unlimited |

These limits are enforced before each mint event — not retroactively — and are required by CoinPort's AML/CTF program under the AUSTRAC framework.

### 4.4 Redemption

CPP is redeemed within the CoinPort platform for benefits including:

- **Free airdrops** — allocations in CoinPort-listed airdrop events.
- **Trading rebates** — discounts applied against trading fees (the most common redemption use).
- **Member benefits** — priority support, exclusive feature access, API rate-limit increases, launchpad whitelist allocations, and approved merchandise.

Redemption is irreversible. Redeemed CPP is permanently burned at the smart-contract level, reducing the on-chain total supply. The redemption catalog is published on the CoinPort platform and is subject to change with 30 days' advance notice.

The AUD $1,000 / calendar year cap applies to the aggregate AUD-equivalent value of all redemptions by a single member across all categories.

### 4.5 Expiration

CPP allocated to a member expires after **24 months of account inactivity**, with at least 30 days' prior notice. Inactivity is defined as no login and no trading activity over the 24-month window. Expiration reinforces CPP's status as a contingent benefit, not property.

---

## 5. Supply schedule

CPP supply is bounded and predictable. The schedule below applies **per chain** — each chain on which CPP is deployed has its own independent on-chain supply, hot wallet, and cap.

| Period | Cumulative supply cap (per chain) |
|---|---|
| Year 1 | 100M CPP |
| Year 2 | 125M CPP (+25M) |
| Year 3 | 140M CPP (+15M) |
| Year 4–7 (terminal cap) | up to 200M CPP |

In addition:

- **Monthly minting cap:** 2M CPP per chain, enforced operationally.
- **Initial launch allocation:** 5M CPP minted at deployment on each chain, held by the cold treasury for launch promotions and initial program funding.
- **No team allocation. No investor allocation. No founder allocation.** CPP has no insiders; all CPP enters circulation through member earning.
- **Deflationary pressure:** every redemption burns CPP on the chain where it is redeemed, reducing that chain's on-chain total supply.
- **Emergency pause:** minting can be paused independently on any chain by the corresponding pauser multi-sig if monthly inflation exceeds 5%, or in response to any abuse, exploit, or compliance incident.

### 5.1 Program-wide supply ceiling

Because each chain is an independent deployment, the **program-wide ceiling** on total CPP outstanding equals the per-chain cap multiplied by the number of supported chains. With five live target chains (Ethereum, BNB Smart Chain, Arbitrum One, Polygon, and Avalanche C-Chain), the program-wide terminal ceiling is **up to 1,000,000,000 (1B) CPP**.

This ceiling reflects on-chain issuance authority, not member-facing accounting. Under the custodial model (§4.1), members hold a single unified balance in the off-chain member ledger; the chain on which the backing token currently sits is an operational detail and may shift over time as CoinPort rebalances liquidity between chains and ecosystems. The AUD $1,000 / calendar year redemption cap (§3.3) is enforced per member globally, not per chain.

The supply schedule is parametric: the 200M per-chain terminal cap is the binding contractual ceiling for each chain, while annual additions within that cap are operationally governed.

---

## 6. Anti-gaming and integrity controls

CPP earning is subject to controls designed to prevent abusive accrual:

- **Wash-trade detection** at the trade-matching layer; coordinated self-matching is excluded from CPP-eligible volume.
- **Minimum trade size and minimum hold time** for CPP-eligible trades.
- **Velocity limits:** maximum 8 CPP-earning events per member per day; maximum 10,000 CPP earned per member per day.
- **Manual review threshold:** members earning more than 50,000 CPP in any rolling 30-day window are flagged for review.
- **Account-level limits** enforced by KYC tier.

Members determined to have gamed the program may have CPP voided, accounts suspended, and reports filed with regulators as required.

---

## 7. Technical architecture

### 7.1 Token standard

CPP is an **ERC-20** token with the following extensions:

- **ERC-20 Mintable** — controlled minting by the loyalty engine.
- **ERC-20 Burnable** — destruction of CPP on redemption.
- **ERC-20 Pausable** — emergency halt of all CPP transfers and mints.
- **ERC-20 Permit (EIP-2612)** — meta-transaction approvals.
- **AccessControl** — role-based privilege separation, replacing single-owner control.

The implementation contract was scaffolded with the OpenZeppelin Contracts Wizard and audited against OpenZeppelin's standard library. CPP-specific compliance features — supply cap, role gating, freeze controls, and the closed-loop guard mechanism — are layered on top of the Wizard-generated base.

### 7.2 Upgradeability

CPP uses the **OpenZeppelin transparent proxy** pattern. The address members and integrators reference (`0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` on each chain) is the proxy; the implementation behind it can be upgraded by the admin multi-sig on that chain. The upgrade window is intended to be limited to the first 12–18 months of program operation, after which the contracts are expected to be made effectively immutable.

The proxy admin is the cold admin multi-sig (see §7.5). No single party — including any CoinPort employee — has unilateral upgrade authority. Upgrades on each chain are governed independently; an upgrade on one chain does not automatically propagate to the other chains.

### 7.3 Multi-chain deployment

The same contract bytecode is deployed independently on each supported chain, at the same contract address (`0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5`). The chains are not bridged: there is no on-chain mechanism that transfers CPP from one chain to another, and there is no canonical "source of truth" chain at the contract level. Each chain's deployment is internally complete and self-consistent.

Multi-chain coverage is a deliberate design choice: each supported chain anchors CPP inside a distinct cryptocurrency ecosystem (Ethereum, BNB, Arbitrum, Polygon, and Avalanche), so the loyalty program is visible and integrable from wallets, indexers, and tooling native to each ecosystem rather than only from Ethereum-first tooling.

Using the same contract address (`0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5`) on every supported chain is itself an operational design choice. It means members, integrators, auditors, and block explorers can recognise CPP by a single canonical identifier regardless of which chain they are querying, simplifying tracking, reconciliation, listing submissions, and member-facing copy. This identity at the address level does not imply any on-chain bridging or cross-chain message passing — the chains remain independent — it only means the same string identifies CPP everywhere it lives.

Cross-chain consistency of program behaviour (member balances, redemption events, supply totals) is maintained at the application layer through CoinPort's unified off-chain member ledger and operational coordination. Members do not see "Ethereum CPP", "BSC CPP", "Arbitrum CPP", "Polygon CPP", or "Avalanche CPP" as separate balances; they see a single CPP balance.

### 7.4 Custody and minting

All minted CPP on each chain is sent to the CoinPort hot wallet at `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256` on that chain. (The same address controls the hot wallet on every chain, but on-chain balances are independent — there are five logical hot-wallet states, one per chain.) Per-member balances are not minted directly to per-member on-chain addresses; they are tracked in the unified CoinPort member ledger. This is the on-chain expression of Model B custody (§4.1).

The hot wallet holds **only** the `MINTER_ROLE` — it cannot pause the contract, change admin, freeze accounts, or perform compliance transfers. Compromise of the hot wallet would allow new CPP to be minted up to the supply cap, but would not allow any other privileged action.

### 7.5 Role separation (multi-sig)

CPP uses four distinct privileged roles on each chain, each held by a separate 3-of-5 Safe{Wallet} multi-sig:

| Role | Function |
|---|---|
| `DEFAULT_ADMIN_ROLE` (cold admin) | Grants/revokes other roles; controls proxy upgrades |
| `MINTER_ROLE` (loyalty hot wallet) | Issues new CPP per the earning engine |
| `PAUSER_ROLE` | Halts transfers/mints in emergency |
| `COMPLIANCE_ROLE` | Account freezes, unfreezes, and complianceTransfer for court orders, sanctions enforcement, and error correction |

No single signer on any multi-sig can take a privileged action alone; every action requires a majority of signers across geographically and organisationally distributed key-holders. Keys are held in hardware wallets.

### 7.6 Compliance functions

The contract supports two compliance primitives required for regulated operation:

- **Address freeze / unfreeze** — held by `COMPLIANCE_ROLE`. Used to suspend a specific address (e.g. a hot wallet flagged in a sanctions update). Members in the custodial model do not have per-address frozen states because they do not have per-address balances; freeze is a contract-administration tool.
- **`complianceTransfer`** — held by `COMPLIANCE_ROLE`. Allows movement of CPP between addresses for court orders, sanctions enforcement, and error correction. All compliance transfers emit indexed events for audit.

These functions are intentionally narrow. They cannot be used for ordinary program operations.

### 7.7 Verification

The contract source code is verified on the canonical block explorer for each supported chain (Etherscan for Ethereum, BscScan for BNB Smart Chain, Arbiscan for Arbitrum One, PolygonScan for Polygon, and Avascan for Avalanche C-Chain) — both proxy and implementation. Members and integrators can:

- Read the token's total supply, paused state, and role assignments directly from the contract.
- Audit every mint and burn from the contract's event log.
- Confirm that the deployed bytecode matches the published source.

---

## 8. Operational model

### 8.1 Daily mint cycle

The loyalty engine processes earning events in a daily cycle:

1. **00:00 UTC** — snapshot of qualifying member activity from the prior day.
2. **00:00–02:00 UTC** — validation, anti-gaming checks, KYC-tier limit enforcement, AML monitoring.
3. **02:00 UTC** — single mint transaction from the hot wallet, increasing total supply by the validated aggregate. The CoinPort member ledger is updated with per-member allocations.

This design minimises on-chain gas cost (one transaction per day, not one per member per event) while maintaining a complete public record of program supply.

### 8.2 Redemption cycle

Redemption is processed in near-real-time at the application layer; the corresponding on-chain burn happens via batched burn transactions from the hot wallet. The off-chain member ledger updates atomically; the on-chain burn lags but reconciles within the same operational cycle.

### 8.3 Reconciliation

Continuous reconciliation between the on-chain CPP supply and the sum of member-ledger balances is part of routine internal audit. Any reconciliation gap is investigated and resolved on the operational cycle in which it is discovered.

### 8.4 Reporting

- **Annual member statements** — CPP redemption values in AUD equivalent are reported to each Australian member by 14 July for the prior financial year.
- **AUSTRAC reporting** — large or suspicious redemption activity is reported via Suspicious Matter Reports (SMRs) and Threshold Transaction Reports per the AML/CTF Act.
- **Regulator engagement** — CoinPort maintains ongoing engagement with ASIC, AUSTRAC, and ATO regarding the CPP program structure.

---

## 9. Regulatory framework

CPP operates in Australia under the regulatory framework summarised here. For full detail, see [`compliance.md`](./compliance.md) and [`legal.md`](./legal.md).

### 9.1 ASIC — "not a financial product"

The four design constraints in §3 collectively keep CPP outside the *Corporations Act 2001* definition of a financial product. CoinPort does not hold an AFSL for the CPP program because the program is not a financial service.

### 9.2 AUSTRAC — AML/CTF

CoinPort is a registered Virtual Asset Service Provider (VASP) with AUSTRAC and operates under the AML/CTF Act 2006. (The VASP regime replaced the earlier Digital Currency Exchange registration framework in Australia.) CPP is integrated into CoinPort's AUSTRAC-approved AML/CTF Program:

- KYC at all earning tiers.
- Transaction monitoring of CPP earning and redemption events.
- Threshold Transaction Reports and Suspicious Matter Reports as required.

The closed-loop, no-fiat-conversion design means CPP itself is **not** a virtual asset within the scope of the VASP regime, but its activity is monitored under the same AML/CTF Program.

### 9.3 ATO — taxation

- Member redemptions may constitute assessable income under TR 2005/15.
- Fee-discount redemptions are treated as a reduction in CoinPort's revenue under GSTR 2014/3; GST is calculated on the discounted fee.
- Merchandise and digital-goods redemptions are taxable supplies; GST applies on market value.
- Members are responsible for declaring their own tax obligations.

### 9.4 ACCC — consumer law

CoinPort provides earning-time disclosures (estimated CPP, no cash value, redemption caps, tax implications) compliant with the Australian Consumer Law. ACL consumer guarantees are not waivable by the T&Cs.

### 9.5 Privacy

CPP-related data is handled under CoinPort's Privacy Policy, in compliance with the Australian Privacy Principles (Privacy Act 1988).

---

## 10. Risks and limitations

### 10.1 Program risks

- **Program changes:** Earning rates, redemption catalog, and program terms may change with 30 days' notice. Members should not treat CPP balances as a fixed-value entitlement.
- **Program termination:** CoinPort may end the program with at least 90 days' notice. Members will have that window to redeem.
- **Expiration:** Inactive balances expire (§4.5).
- **Custodial risk:** Because CPP is custodial, members rely on CoinPort to honour their member-ledger balance. CoinPort's exchange-grade custody controls apply.

### 10.2 Smart-contract risks

- **Upgrade authority exists** for the first 12–18 months on each chain. While protected by multi-sig and intended to be retired, upgrade authority means the contracts' behaviour is not strictly immutable today.
- **Pause authority exists.** A pause halts CPP movement on the affected chain; it does not affect off-chain member balances or other chains.
- **Compromise of any role multi-sig** would compromise the corresponding privilege on the chain to which that multi-sig is bound. Multi-sig and geographically distributed key custody substantially reduce, but do not eliminate, this risk.
- **Per-chain blast radius.** Because chains are independent, an incident on one chain (pause, upgrade error, freeze) does not contaminate the others. The corollary is that an incident must be remediated on each affected chain separately.

### 10.3 Multi-chain risks

- **Per-chain supply caps, program-wide ceiling.** The 200M terminal cap is enforced per chain. The program-wide on-chain issuance ceiling is therefore the per-chain cap multiplied by the number of supported chains (currently up to 1B CPP across Ethereum, BNB Smart Chain, Arbitrum One, Polygon, and Avalanche C-Chain). Members should not interpret the 200M figure as a program-wide ceiling.
- **Independent role multi-sigs per chain.** Each chain has its own set of admin, pauser, minter, and compliance multi-sigs. Operational mistakes (signer key loss, incorrect role assignment) can occur on each chain.
- **Underlying chain risks.** Each chain has its own security model, consensus assumptions, and historical incidents. BNB Smart Chain, Polygon, Arbitrum One (an Ethereum L2 with sequencer-based finality), and Avalanche C-Chain all have materially different validator and finality properties from Ethereum mainnet. CoinPort does not represent these chains as equivalent in security to Ethereum mainnet.
- **Reorg / reorganisation risk.** Non-Ethereum chains have historically experienced deeper or longer reorgs than Ethereum mainnet, and Arbitrum One depends on its sequencer for soft finality before Ethereum L1 settlement. Earning and redemption transactions on those chains may be subject to longer confirmation windows in CoinPort's internal reconciliation.

### 10.4 Regulatory risks

- **Regulatory change.** Australian regulators may change their position on loyalty tokens; CoinPort may need to amend the program in response.
- **Cross-border use.** Non-Australian members are responsible for the application of their local laws.
- **Future program changes** that materially alter the four design constraints (§3) would require fresh legal review before implementation.

### 10.5 What CPP is not

To be unambiguous:

- CPP is **not an investment.** Do not expect profit.
- CPP is **not a cryptocurrency for payments outside CoinPort.** It cannot be spent elsewhere.
- CPP is **not a stablecoin.** It has no peg.
- CPP is **not a governance token.** Holding CPP does not confer voting rights over CoinPort.
- CPP is **not for sale.** There is no purchase path, public or private.

---

## 11. Roadmap

The CPP roadmap is intentionally narrow. The program is a loyalty scheme, not a product line.

- **Phase 1 (current):** Earning channels live (trading volume, holding, activity, referral). Redemption catalog live for trading rebates and member benefits. Daily batch processing operational.
- **Phase 2:** Expansion of the redemption catalog to include free airdrops in CoinPort-listed events, and launchpad-allocation whitelisting. Anti-gaming refinement.
- **Phase 3:** Maturation. Once the program is operationally stable, the contract is expected to be made effectively immutable by retiring the upgrade authority.

The earlier design literature (`actions.md`, `standard.md`) contemplated a future "two-token" governance extension. **That is not a roadmap commitment.** Any move in that direction would require a fresh legal opinion and would be communicated to members in advance; it would likely require restructuring of the program and is outside the scope of CPP as documented in this white paper.

---

## 12. Governance of program changes

CPP is a CoinPort-operated program. There is no on-chain governance, no member voting, no DAO. Program changes are decided by CoinPort and communicated to members with the required notice periods (typically 30 days for earning/redemption changes, 90 days for program termination).

Material changes to the four design constraints in §3 — for example, enabling external transfers or fiat redemption — would constitute a fundamental change to the program's regulatory posture and would not be made without external legal review and member notice.

---

## 13. References and contact

### Source documents (this repository)

- [`terms.md`](./terms.md) — binding member Terms & Conditions.
- [`earning.md`](./earning.md) — earning mechanics specification.
- [`compliance.md`](./compliance.md) — Australian compliance framework.
- [`legal.md`](./legal.md) — internal legal-situation summary.
- [`actions.md`](./actions.md) — original implementation blueprint.
- [`standard.md`](./standard.md) — token-standard selection rationale.
- [`docs/deploy.md`](./docs/deploy.md) — deployment procedure of record.

### Contracts and addresses

The same contract bytecode and the same contract address are used on each supported chain.

| Chain | Status | Token contract (proxy) | Explorer |
|---|---|---|---|
| Ethereum mainnet (id 1) | Live 2026-05-18 | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [Etherscan](https://etherscan.io/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |
| BNB Smart Chain (id 56) | Live | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [BscScan](https://bscscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |
| Arbitrum One (id 42161) | Live 2026-05-19 | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [Arbiscan](https://arbiscan.io/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |
| Polygon (id 137) | Live 2026-05-19 | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [PolygonScan](https://polygonscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |
| Avalanche C-Chain (id 43114) | Live 2026-05-19 | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [Avascan](https://avascan.info/blockchain/c/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |

| | |
|---|---|
| Hot wallet (`MINTER_ROLE`, all chains) | `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256` |
| Standard | ERC-20 + Mintable + Burnable + Pausable + Permit + AccessControl, transparent proxy |

### Issuer

**CoinPort Pty Ltd**
Website: https://www.coinport.com.au
Program contact: network@coinport.exchange

For terms, dispute resolution, AFCA membership details, and other contact information, refer to [`terms.md`](./terms.md) §16.

---

*This document is informational. The binding rules of the CPP program are set out in [`terms.md`](./terms.md). Where this document and the T&Cs conflict, the T&Cs prevail. This document does not constitute legal, financial, tax, or investment advice.*
