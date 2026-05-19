## **COINPORT LOYALTY PROGRAM - AUSTRALIAN COMPLIANCE FRAMEWORK**

### **1. REGULATORY LANDSCAPE ANALYSIS**

**Key Regulators & Laws:**
- **ASIC** (Corporations Act 2001, ASIC Act 2001)
- **AUSTRAC** (Anti-Money Laundering and Counter-Terrorism Financing Act 2006)
- **ACCC** (Australian Consumer Law)
- **Privacy Act 1988** (Australian Privacy Principles)
- **Taxation Ruling TR 2005/15** (Loyalty program taxation)

### **2. CRITICAL LEGAL DESIGN PRINCIPLES**

#### **A. Avoid "Financial Product" Classification**
According to ASIC's [INFO 225](https://asic.gov.au/regulatory-resources/digital-transformation/initial-coin-offerings-and-crypto-assets/), a token becomes a financial product if it:
- Functions as a security, derivative, or managed investment scheme
- Is traded on secondary markets
- Has speculative investment characteristics

**Compliance Strategy:**
1. **Closed-loop system only** - No external transfers, no secondary market trading
2. **Non-transferable points** - Implement contract-level transfer restrictions
3. **Fixed redemption value** - Establish CPP as "points" not "currency"
4. **No profit expectation** - Market as discount/reward program, not investment

#### **B. AML/CTF Compliance (AUSTRAC)**
**Enhanced Requirements:**
- Customer identification (KYC) for all loyalty program participants
- Transaction monitoring for CPP earning/spending
- Threshold reporting for large CPP accruals
- Suspicious matter reporting for gaming/exploitation

### **3. TOKEN STRUCTURE - COMPLIANT DESIGN**

> **Deployed contracts:** The CPP token is live at proxy address `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` on five public EVM chains: [Ethereum mainnet](https://etherscan.io/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) (canonical, since 2026-05-18), [BNB Smart Chain](https://bscscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5), [Arbitrum One](https://arbiscan.io/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5), [Polygon](https://polygonscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5), and [Avalanche C-Chain](https://avascan.info/blockchain/c/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) — the latter three went live on 2026-05-19. Each is a sibling deployment, not bridged. The Solidity snippet below describes the design-intent transfer guard; the as-deployed contracts have the closed-loop guard disabled on every chain (operational decision recorded against this contract — see `MEMORY.md`). Closed-loop behaviour is currently enforced at the application layer and via the T&Cs in `terms.md` §7, not by the on-chain `_update` hook. The compliance analysis in the rest of this document applies equally to all five chains on which CPP is deployed.

#### **Smart Contract Modifications:**
```solidity
// CRITICAL: Transfer restrictions compliant with closed-loop requirement
contract CPPToken is ERC20 {
    bool public transfersEnabled = false; // Default DISABLED
    
    // Only allow transfers between whitelisted addresses (CoinPort users)
    function transfer(address to, uint256 amount) public override returns (bool) {
        require(transfersEnabled, "CPP: Transfers disabled per Australian regulations");
        require(isKYCVerified[msg.sender] && isKYCVerified[to], "CPP: Both parties must be KYC-verified");
        require(!isSanctioned[msg.sender] && !isSanctioned[to], "CPP: Sanctioned address");
        return super.transfer(to, amount);
    }
    
    // Admin override for compliance/legal orders
    function complianceTransfer(
        address from, 
        address to, 
        uint256 amount
    ) external onlyComplianceOfficer {
        // For: Court orders, error corrections, sanctions enforcement
        _transfer(from, to, amount);
    }
}
```

### **4. PROGRAM TERMS & CONDITIONS - KEY CLAUSES**

#### **Essential T&C Provisions:**
```legal
1. NATURE OF POINTS
   "CoinPort Points (CPP) are a proprietary loyalty reward system with no cash value.
   CPP are not securities, financial products, or digital currencies under Australian law.
   CPP cannot be converted to fiat currency, transferred externally, or used as payment outside CoinPort."

2. REDEMPTION RESTRICTIONS
   "CPP may only be redeemed for benefits explicitly listed in the CoinPort rewards catalog.
   Redemption values are set at CoinPort's discretion and may change with 30 days notice.
   Maximum redemption value per user: AUD $1,000 per calendar year (GST inclusive)."

3. TAX TREATMENT
   "CPP earnings may constitute assessable income under TR 2005/15 when redeemed.
   Users are responsible for declaring taxable benefits. CoinPort will provide annual statements.
   CPP earned from trading may be treated as discount on trading fees (input tax credits apply)."

4. ANTI-GAMING
   "CoinPort reserves right to void points earned through abusive practices including:
   - Wash trading, self-matching, or artificial volume generation
   - Multi-accounting or collusive behavior
   - Exploitation of system errors
   Suspicious accounts may be suspended pending AUSTRAC/ASIC reporting requirements."
```

### **5. AML/CTF SPECIFIC IMPLEMENTATIONS**

#### **Transaction Monitoring Rules:**
```sql
-- CPP-Specific AML Monitoring
CREATE TABLE cpp_aml_flags (
    flag_id UUID PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id),
    rule_triggered VARCHAR(100),
    scenario VARCHAR(50), -- 'RAPID_ACCUMULATION', 'STRUCTURED_REDEMPTION', etc.
    
    -- Threshold-based triggers
    threshold_type VARCHAR(30), -- 'DAILY_EARNINGS', 'MONTHLY_REDEMPTIONS'
    threshold_value DECIMAL(24,8),
    actual_value DECIMAL(24,8),
    
    -- Investigation tracking
    status VARCHAR(20) DEFAULT 'NEW', -- NEW, INVESTIGATING, SAR_FILED, RESOLVED
    assigned_to VARCHAR(100), -- Compliance officer
    investigation_notes TEXT,
    
    -- AUSTRAC Reporting
    sars_filed BOOLEAN DEFAULT FALSE,
    sars_reference VARCHAR(50),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- Mandatory reporting thresholds
INSERT INTO cpp_aml_thresholds (threshold_name, limit_value, reporting_required) VALUES
    ('DAILY_CPP_EARNED', 10000, 'MONITOR'), -- ~AUD $100 value
    ('DAILY_CPP_EARNED', 50000, 'SAR_REVIEW'), -- ~AUD $500
    ('MONTHLY_REDEMPTION_VALUE', 10000, 'SMR'), -- AUD $10,000 = SMR threshold
    ('SUSPICIOUS_PATTERN', NULL, 'SAR_MANDATORY');
```

#### **Customer Identification Program (CIP):**
```sql
-- Enhanced KYC for loyalty program
ALTER TABLE users ADD COLUMN loyalty_tier_kyc_status VARCHAR(20) DEFAULT 'BASIC';
-- BASIC: Email verified only (earn up to 100 CPP/month)
-- STANDARD: Photo ID verified (earn up to 10,000 CPP/month)  
-- ENHANCED: Source of wealth verified (unlimited, required for >AUD $10k annual value)

CREATE TABLE cpp_kyc_limits (
    kyc_tier VARCHAR(20) PRIMARY KEY,
    max_monthly_earnings DECIMAL(24,8),
    max_balance DECIMAL(24,8),
    max_redemption_monthly_aud DECIMAL(10,2),
    requires_documentation BOOLEAN
);

INSERT INTO cpp_kyc_limits VALUES
    ('BASIC', 100, 1000, 100, FALSE),
    ('STANDARD', 10000, 100000, 1000, TRUE),
    ('ENHANCED', 1000000, 1000000, 10000, TRUE);
```

### **6. TAX COMPLIANCE FRAMEWORK**

#### **GST Treatment (Based on ATO GSTR 2014/3):**
```
CPP REDEMPTION SCENARIOS:

1. Fee Discounts (Primary use):
   - CPP used for trading fee discount = Reduced fee revenue
   - GST applies to actual fee charged (post-discount)
   - No separate GST on CPP issuance/redemption

2. Physical Goods Redemption:
   - CPP redeemed for merchandise = Taxable supply
   - GST payable on market value of goods
   - Requires valid ABN registration for suppliers

3. Digital Goods/Subscriptions:
   - GST applies based on recipient's location
   - CPP value converted to AUD at redemption date spot rate
```

#### **Tax Reporting System:**
```sql
CREATE TABLE cpp_tax_records (
    tax_record_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(user_id),
    financial_year INTEGER, -- 2024, 2025
    record_type VARCHAR(30), -- 'ISSUANCE', 'REDEMPTION', 'EXPIRY'
    
    -- Value calculations
    cpp_amount DECIMAL(24,8),
    aud_value DECIMAL(10,2), -- CPP value in AUD at transaction time
    gst_amount DECIMAL(10,2),
    
    -- For ATO reporting
    is_taxable_event BOOLEAN,
    tax_code VARCHAR(10), -- Based on ATO product codes
    bsb_account_required BOOLEAN DEFAULT FALSE, -- For cash equivalents
    
    -- User reporting
    included_in_statement BOOLEAN DEFAULT FALSE,
    statement_generated_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    INDEX idx_user_financial_year (user_id, financial_year)
);

-- Annual statement generation procedure
CREATE OR REPLACE PROCEDURE generate_cpp_annual_statements(fy_year INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Generate ATO-compliant annual statements
    INSERT INTO user_tax_statements (...)
    SELECT 
        u.user_id,
        u.tax_file_number, -- Only if collected
        fy_year,
        SUM(CASE WHEN r.record_type = 'REDEMPTION' THEN r.aud_value ELSE 0 END) as total_benefits,
        COUNT(DISTINCT CASE WHEN r.is_taxable_event THEN r.tax_record_id END) as taxable_events_count
    FROM users u
    LEFT JOIN cpp_tax_records r ON u.user_id = r.user_id 
        AND r.financial_year = fy_year
    WHERE u.country_code = 'AU'
    GROUP BY u.user_id, u.tax_file_number;
    
    -- Flag as reported
    UPDATE cpp_tax_records 
    SET included_in_statement = TRUE,
        statement_generated_at = NOW()
    WHERE financial_year = fy_year;
END;
$$;
```

### **7. CONSUMER LAW COMPLIANCE (ACCC)**

#### **Transparency Requirements:**
```javascript
// Mandatory disclosures in UI/UX
const loyaltyDisclosures = {
    earningRate: "CPP are earned at approximately 1 CPP per $1,000 of trading volume",
    expiration: "CPP expire after 24 months of inactivity (with 30 days notice)",
    value: "CPP have no guaranteed value. Current redemption: 1 CPP ≈ $0.01 AUD in fee discounts",
    changes: "Program terms may change with 30 days advance notice",
    complaints: "Disputes handled via internal process, then AFCA if eligible",
    privacy: "CPP earnings data shared only as required by AUSTRAC/ATO"
};

// Real-time disclosure on earning screens
function showEarningDisclosure() {
    return `
        You will earn approximately ${estimatedCPP} CPP from this trade.
        * CPP have no cash value and cannot be transferred externally
        * Maximum redemption value: AUD $1,000 per calendar year
        * CPP may constitute taxable benefits when redeemed
        [See full terms]
    `;
}
```

### **8. OPERATIONAL COMPLIANCE CHECKLIST**

#### **Pre-Launch Requirements:**
- [ ] **Legal Opinion:** Obtain formal advice on CPP structure from Australian financial services lawyer
- [ ] **AFCA Membership:** Register with Australian Financial Complaints Authority
- [ ] **Privacy Policy:** Update for CPP data collection (Privacy Act compliance)
- [ ] **AML Program Enhancement:** Update AML/CTF Program to include CPP monitoring
- [ ] **Tax Advice:** Formal ATO ruling request on CPP GST treatment (optional but recommended)
- [ ] **Board Approval:** Document program approval with compliance considerations

#### **Ongoing Compliance:**
- [ ] **Monthly AUSTRAC Reporting:** Include CPP transactions in SMR if thresholds met
- [ ] **Quarterly ASIC Review:** Monitor for "financial product" boundary risks
- [ ] **Annual Tax Statements:** Generate by July 14 for previous financial year
- [ ] **Bi-annual Policy Review:** Update T&Cs based on regulatory changes
- [ ] **Regular Audits:** Internal audit of CPP issuance/redemption processes

### **9. RISK MITIGATION STRATEGIES**

#### **Regulatory Risk Scenarios:**
```sql
-- Compliance monitoring dashboard queries
WITH risk_indicators AS (
    SELECT 
        'SECONDARY_MARKET' as risk_type,
        COUNT(*) as occurrences
    FROM cpp_ledger 
    WHERE reference_id LIKE '%external%' 
       OR metadata->>'platform' != 'coinport'
    
    UNION ALL
    
    SELECT 
        'HIGH_VALUE_CONCENTRATION',
        COUNT(DISTINCT user_id)
    FROM users 
    WHERE current_cpp_balance > 100000 
       AND loyalty_tier_kyc_status != 'ENHANCED'
    
    UNION ALL
    
    SELECT 
        'RAPID_ACCUMULATION',
        COUNT(*)
    FROM (
        SELECT user_id, SUM(amount) as daily_cpp
        FROM cpp_ledger 
        WHERE created_at::DATE = CURRENT_DATE
        GROUP BY user_id
        HAVING SUM(amount) > 50000
    ) rapid_earners
)
SELECT * FROM risk_indicators WHERE occurrences > 0;
```

### **10. RECOMMENDED COMPLIANCE STAFFING**

**Minimum Roles Required:**
1. **Compliance Officer (AML/CTF):** Daily monitoring, AUSTRAC reporting
2. **Tax Specialist:** GST treatment, ATO reporting, annual statements
3. **Legal Counsel (Part-time):** Regulatory updates, T&C maintenance
4. **Customer Support (Trained):** CPP dispute resolution, AFCA liaison

**Estimated Compliance Costs:**
- Legal setup: AUD $15,000-$25,000 (one-time)
- Annual compliance: AUD $50,000-$75,000 (staffing + systems)
- Audit costs: AUD $10,000-$15,000 annually
- AFCA membership: ~AUD $2,500 annually

---

## **IMMEDIATE ACTION PLAN:**

### **Phase 1: Regulatory Engagement (Week 1-4)**
1. Schedule pre-implementation meetings with ASIC Innovation Hub
2. Engage specialized Australian fintech legal firm
3. Draft CPP White Paper with legal section on regulatory analysis

### **Phase 2: Documentation (Week 5-8)**
1. Finalize CPP Terms & Conditions (Australian Consumer Law compliant)
2. Update AML/CTF Program document
3. Create Privacy Policy addendum for CPP data
4. Draft user agreements with mandatory disclosures

### **Phase 3: System Implementation (Week 9-16)**
1. Implement transfer-restricted smart contract
2. Build KYC-gated earning limits
3. Develop AUSTRAC reporting integration
4. Create tax statement generation system

### **Phase 4: Soft Launch (Week 17-20)**
1. Launch to 100 verified Australian users only
2. Monitor for regulatory feedback
3. Adjust based on initial compliance observations
4. Full launch with all compliance controls active

---

## **KEY REGULATORY REFERENCES:**

1. **ASIC Regulatory Guide 234** (Advertising financial products)
2. **AUSTRAC Guidance Note 1/2022** (Digital currency exchange obligations)
3. **ATO Taxation Ruling TR 2005/15** (Loyalty programs)
4. **ASIC INFO 225** (Crypto-assets as financial products)
5. **Privacy Act 1988** (Australian Privacy Principles)

---
