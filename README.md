# CoinPort Loyalty Points (CPP)

CoinPort Loyalty Program token. Multi-chain ERC-20 with Ethereum mainnet as the canonical deployment, also live on four additional EVM ecosystems.

## Deployments

| Chain | Status | Contract address | Explorer |
|---|---|---|---|
| Ethereum mainnet (id 1) | **Live** since 2026-05-18 | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [Etherscan](https://etherscan.io/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |
| BNB Smart Chain (id 56) | **Live** | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [BscScan](https://bscscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |
| Arbitrum One (id 42161) | **Live** 2026-05-19 | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [Arbiscan](https://arbiscan.io/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |
| Polygon (id 137) | **Live** 2026-05-19 | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [PolygonScan](https://polygonscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |
| Avalanche C-Chain (id 43114) | **Live** 2026-05-19 | `0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5` | [Avascan](https://avascan.info/blockchain/c/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) |

The same contract bytecode is deployed independently on each chain — these are sibling deployments, not bridged. Each chain maintains its own supply, its own hot wallet, and its own role multi-sigs. Ethereum is the canonical chain for member-facing copy and regulatory references; the other four chains exist to give CPP a presence inside several distinct cryptocurrency ecosystems (Ethereum, BNB, Arbitrum, Polygon, Avalanche) and to provide lower-cost user interactions within each.

## Quick facts

- **Standard:** ERC-20 (Mintable, Burnable, Pausable, Permit) + AccessControl, behind transparent proxy
- **Custody:** Model B (custodial) — minted supply held by hot wallet `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256` on each chain
- **Member ledger:** off-chain, unified across chains
- **Issuer:** CoinPort Exchange Pty Ltd, registered VASP (AUSTRAC)

See `whitepaper.md`, `actions.md`, `compliance.md`, `terms.md`, and `legal.md` for design, regulatory, and user-terms detail. Deployment procedure: `docs/deploy.md`.
