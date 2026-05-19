# CoinPort Loyalty Points (CPP) — Australian Legal Situation Summary

**Disclaimer:** This document is an internal summary of the legal framework already developed in `compliance.md` and `terms.md`, plus open risks worth raising with counsel. It is **not legal advice**.

**Deployment status (2026-05-19):** The CPP token contract is live at proxy address `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` on five public EVM chains: [Ethereum mainnet](https://etherscan.io/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) (canonical, since 2026-05-18), [BNB Smart Chain](https://bscscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5), [Arbitrum One](https://arbiscan.io/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5), [Polygon](https://polygonscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5), and [Avalanche C-Chain](https://avascan.info/blockchain/c/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) — the latter three went live on 2026-05-19. Each chain is an independent sibling deployment with its own supply, hot wallet, and role multi-sigs. The `compliance.md` Phase 1 "formal legal opinion before mainnet" gate was the documented pre-launch action; if it has not been satisfied, the open items in §5 below should be raised with counsel as a matter of priority rather than treated as roadmap notes.

---

## 1. The core legal question

Whether CPP is a **"financial product"** under the *Corporations Act 2001*.

- **If yes:** CoinPort needs an AFSL (Australian Financial Services Licence) for the loyalty program itself, on top of its AUSTRAC VASP registration.
- **If no:** The program runs as a normal commercial loyalty scheme with AML/tax overlays.

ASIC INFO 225 says a token becomes a financial product when it:
- Functions as a security, derivative, or managed investment scheme
- Trades on secondary markets
- Has speculative investment characteristics

The CPP design is deliberately built to fail all three tests.

---

## 2. How the design avoids "financial product" status

These are the load-bearing legal features (`compliance.md` §2A, `terms.md` §3, §7):

| Feature | Legal purpose |
|---|---|
| Closed-loop, transfers disabled by default | Prevents secondary market formation |
| AUD $1,000/user/calendar year redemption cap | Caps individual exposure; reinforces "loyalty program" framing |
| No fiat conversion, ever | Removes "currency" / "investment" characterization |
| Fixed redemption catalog (1 CPP ≈ $0.01 fee discount) | Keeps value administrative, not market-determined |
| 24-month inactivity expiration | Reinforces CPP as a benefit, not property |
| KYC-gated earning tiers | AML compliance + caps speculative accumulation |
| "No profit expectation" T&Cs | Direct response to the *Howey*-style profit-from-others'-efforts test ASIC also references |

**If any of these slips** — particularly transfers becoming possible without strict KYC gating, or CPP being convertible to fiat — the analysis flips and the program likely becomes a regulated financial product.

---

## 3. The four parallel regulatory regimes

Even after "not a financial product" is cleared, four other regimes apply.

### 3.1 AUSTRAC (AML/CTF Act 2006)

CoinPort is already an AUSTRAC-registered Virtual Asset Service Provider (VASP) — the regime that replaced the earlier Digital Currency Exchange registration in Australia (registration number placeholder in `terms.md` §1.1 and §16). CPP earnings/redemptions must fold into the existing AML/CTF Program:

- KYC at all earning tiers
- Transaction monitoring for CPP earning/spending
- Suspicious Matter Reports (SMRs) for suspicious patterns
- Threshold Transaction Reports for large redemptions
- IFTIs where applicable

The SQL schemas in `compliance.md` §5 sketch the monitoring tables (`cpp_aml_flags`, `cpp_kyc_limits`).

### 3.2 ATO (TR 2005/15 + GSTR 2014/3)

- CPP redemptions may be **assessable income to the user** under the loyalty program ruling.
- **Fee discounts** are a reduction in revenue, not a separate taxable supply — GST applies to the post-discount fee.
- **Physical merchandise redemptions** are taxable supplies — GST payable on market value.
- **Annual statements** due by July 14 for the prior financial year.
- **Open question:** whether to seek a private ATO ruling on CPP's GST treatment. `compliance.md` §8 marks this as "optional but recommended" — push toward "required" if redemption volume will be material.

### 3.3 ACCC (Australian Consumer Law)

- Mandatory disclosures at earning time: estimated CPP, no cash value, redemption caps, tax implications. `compliance.md` §7 has the disclosure template.
- **ACL consumer guarantees cannot be waived** by T&Cs — `terms.md` §13.3 acknowledges this.
- **Misleading-or-deceptive-conduct risk:** marketing CPP as "rewards" is fine; marketing as "investment", "currency", or implying secondary market resale would invite ACCC attention.

### 3.4 Privacy Act 1988 (APPs)

Standard APP obligations for KYC and earning/redemption data. The repo's privacy hook is in `terms.md` §10, but a **Privacy Policy addendum** specifically for the CPP data flow is required.

---

## 4. Operational compliance burden

From `compliance.md` §10:

| Item | Cost (AUD) |
|---|---|
| One-time legal setup | $15,000 – $25,000 |
| Annual compliance staffing + systems | $50,000 – $75,000 |
| Annual audit | $10,000 – $15,000 |
| AFCA membership | ~$2,500 / year |

**Required roles:** AML/CTF Compliance Officer, tax specialist, part-time legal counsel, trained CS for AFCA disputes.

---

## 5. Gaps in the in-repo framework — flag to counsel

Items `compliance.md` does not fully resolve:

1. **Phase 2 transfers.** `actions.md` proposes enabling peer-to-peer transfers "between verified CoinPort users" later. Even KYC-gated, the moment users can move CPP between themselves, ASIC's secondary-market test gets harder to defend. **This phase should be a hard legal gate, not a roadmap line item.**
2. **The "two-token future"** in `standard.md` (converting CPP to a governance token via vesting). A governance token with voting rights and convertibility almost certainly **is** a financial product — this is a fresh AFSL conversation, not an extension of the existing legal opinion.
3. **Cross-border users.** The framework assumes Australian residents. Non-AU users introduce sanctions/OFAC overlay, possibly GDPR, and host-country tax-reporting questions. `terms.md` §8.4 punts this to the user, which is reasonable but worth confirming with counsel.
4. **TFN collection** for tax statement generation — currently optional (`compliance.md` §6 stored procedure assumes "if collected"). Compliance team should decide whether to require it for Enhanced KYC tier.
5. **VASP registration boundary.** CPP is structured to *not* be a virtual asset within the VASP regime scope, so it sits outside the VASP registration boundary — but the AML/CTF Program covers it. That distinction needs to be explicit in the AML/CTF Program update, otherwise AUSTRAC may treat CPP transactions as in-scope VASP activity.
6. **State-of-residence variations.** AFSL/AFCA are federal, but tax treatment of redeemed benefits can interact with state-level payroll/FBT rules if CoinPort employees earn CPP — minor, but worth a line in the legal opinion.
7. **Multi-chain deployment.** CPP is now live on five public EVM chains: Ethereum mainnet (canonical), BNB Smart Chain, Arbitrum One, Polygon, and Avalanche C-Chain. The four design constraints (closed-loop, no fiat conversion, AUD $1,000/year redemption cap, fixed catalog) are enforced operationally and via the T&Cs, not by the on-chain `_update` hook, so the multi-chain expansion does not change the core ASIC analysis. Three derived items to confirm with counsel: (a) each chain has its own independent 200M cap, so program-wide on-chain issuance authority is now up to **1B CPP** — this should be acknowledged in member-facing copy and is, in `whitepaper.md` §5.1; (b) the AML/CTF Program should explicitly cover transaction monitoring across all five chains, not just Ethereum; (c) the public framing positions the multi-chain set as an ecosystem-integration choice (CPP being present inside several distinct cryptocurrency ecosystems), not as a fundraising or speculative-distribution mechanism — keeping that "ecosystem reach, not financial product reach" framing consistent in external copy reduces the risk of ASIC treating the multi-chain footprint as evidence of secondary-market intent.

---

## 6. Bottom line

The design is **legally defensible as a non-financial-product loyalty program** as long as the four design constraints (closed-loop, redemption cap, no fiat conversion, fixed catalog) hold. The compliance overhead is non-trivial but routine for an AUSTRAC-registered exchange.

The **two real legal risks** are:

1. **Feature creep** that breaks one of the four design constraints.
2. **Phase 2 / two-token roadmap items**, each of which should trigger a fresh legal opinion before implementation rather than be treated as a natural extension.

The token contract is already deployed at [`0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5`](https://etherscan.io/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5). The `compliance.md` Phase 1 step — formal opinion from an Australian fintech legal firm — was the documented pre-launch gate; if not yet obtained, prioritise it before opening the program to users.
