# CPP Deployment Procedure — Windows + Quicknode

End-to-end procedure for publishing `CoinPortLoyaltyPoints` to Ethereum L1 mainnet from a Windows PC, using a Quicknode RPC subscription.

Foundry runs natively on Windows. The one quirk: `foundryup` (the installer) needs a bash-like shell, so install **Git for Windows** (which includes Git Bash) and use that for the install step. Everything afterwards works in PowerShell or Git Bash.

---

## 1 — One-time install (Git Bash)

Install Git for Windows: https://git-scm.com/download/win → use defaults.

Open **Git Bash** and run:

```bash
curl -L https://foundry.paradigm.xyz | bash
# Close & reopen Git Bash, then:
foundryup
```

Verify (PowerShell or Git Bash):

```powershell
forge --version
cast --version
```

## 2 — Pull deps and confirm the project builds

In PowerShell from `C:\storage\git\coinport\token`:

```powershell
git submodule update --init --recursive
forge build
forge test -vv
```

If `forge test` is not green, stop and fix before touching real money.

## 3 — Provision the role multi-sigs (browser)

In the Windows browser, at https://app.safe.global, create four Safe{Wallet} multi-sigs (3-of-5 recommended). Each costs a small amount of mainnet gas to deploy:

| Role | Safe |
|---|---|
| `CPP_TREASURY_ADDRESS` | Cold treasury Safe — receives 5M CPP at launch |
| `CPP_ADMIN_ADDRESS` | Cold admin Safe — owns ProxyAdmin + `DEFAULT_ADMIN_ROLE` |
| `CPP_PAUSER_ADDRESS` | Pauser Safe |
| `CPP_COMPLIANCE_ADDRESS` | Compliance Safe — freeze/unfreeze/complianceTransfer |

`CPP_MINTER_ADDRESS` is the existing hot wallet `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256`.

`script/Deploy.s.sol:43-44` enforces `treasury ≠ minter` and `admin ≠ minter`.

## 4 — Provision a fresh deployer EOA

This EOA signs the two deploy transactions, then gets retired. Two options:

- **Software key** (simpler, lower security): MetaMask → create a brand-new account → export the private key.
- **Hardware key** (recommended): plug a Ledger in via USB; Foundry can sign through `--ledger`.

Fund the deployer with **~0.5 ETH** from an exchange or a funded wallet.

## 5 — Get RPC + Etherscan keys

- **Quicknode dashboard:** create one Ethereum Mainnet endpoint and one Ethereum Sepolia endpoint. Copy both HTTPS URLs.
- **Etherscan:** sign in → API Keys → create one. Copy the key.

## 6 — Configure `.env`

In PowerShell:

```powershell
Copy-Item .env.example .env
notepad .env
```

Fill in:

```
PRIVATE_KEY=0x<deployer-key>          # leave blank if using --ledger
MAINNET_RPC_URL=https://<your>.quiknode.pro/<token>/
SEPOLIA_RPC_URL=https://<your>.ethereum-sepolia.quiknode.pro/<token>/
ETHERSCAN_API_KEY=<key>
CPP_TREASURY_ADDRESS=0x...
CPP_ADMIN_ADDRESS=0x...
CPP_PAUSER_ADDRESS=0x...
CPP_MINTER_ADDRESS=0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256
CPP_COMPLIANCE_ADDRESS=0x...
```

Save. Don't commit it — verify `.gitignore` excludes `.env` before any `git push`.

Treat the Quicknode URL as a secret: the auth token is embedded in the path, so anyone with the URL can spend your request quota.

## 7 — Load `.env` in PowerShell

PowerShell doesn't auto-load `.env`. Use this each new session:

```powershell
Get-Content .env | Where-Object { $_ -and -not $_.StartsWith('#') } | ForEach-Object { $name, $value = $_ -split '=', 2; Set-Item -Path "Env:$name" -Value $value}
```

## 8 — Sepolia rehearsal (mandatory)

Fund the deployer with ~0.1 Sepolia ETH from https://sepoliafaucet.com.

```powershell
forge script script/Deploy.s.sol:DeployCPP --rpc-url $env:SEPOLIA_RPC_URL --private-key $env:PRIVATE_KEY --broadcast --verify --slow

forge script script/Deploy.s.sol:DeployCPP --rpc-url $env:MAINNET_RPC_URL --private-key $env:PRIVATE_KEY --broadcast --verify --slow
```

(Swap `--private-key $env:PRIVATE_KEY` for `--ledger` if using hardware.)

On sepolia.etherscan.io, confirm against the proxy address:

- `transfersEnabled()` → `false`
- `totalSupply()` → `5000000000000000000000000`
- `balanceOf(<treasury>)` → same
- Both Proxy and Implementation show the green "Contract Source Code Verified" badge

Also do one freeze/unfreeze through the compliance Safe to prove the multi-sig flow before mainnet.

## 9 — Mainnet dry-run (no broadcast)

```powershell
forge script script/Deploy.s.sol:DeployCPP `
  --rpc-url $env:MAINNET_RPC_URL `
  --sender <deployer-address>
```

Note the printed gas-used per tx. Check current basefee at https://etherscan.io/gastracker. Multiply, add ~30% headroom — that's your real ETH need. Top the deployer up if short.

## 10 — Mainnet broadcast

Pick a low-gas window (< 20 gwei on gastracker, usually weekends/off-hours).

```powershell
forge script script/Deploy.s.sol:DeployCPP `
  --rpc-url $env:MAINNET_RPC_URL `
  --private-key $env:PRIVATE_KEY `
  --broadcast --verify --slow
```
forge script script/Deploy.s.sol:DeployCPP --rpc-url $env:MAINNET_RPC_URL --private-key $env:PRIVATE_KEY --broadcast --verify --slow

`--slow` waits for each tx to be mined before sending the next — important so the proxy tx doesn't get stuck waiting on the impl.

Save the printed **Proxy address** and **Implementation address**.

## 11 — Post-deploy verification

On https://etherscan.io against the proxy address:

- Both contracts verified.
- "Read as Proxy" shows `transfersEnabled = false`, `totalSupply = 5_000_000e18`, `balanceOf(treasury) = 5_000_000e18`.
- ProxyAdmin owner = the cold admin Safe.

Spot-check from PowerShell:

```powershell
cast call <PROXY> "transfersEnabled()(bool)" --rpc-url $env:MAINNET_RPC_URL
cast call <PROXY> "totalSupply()(uint256)" --rpc-url $env:MAINNET_RPC_URL
```

## 12 — Lock down

- Sweep any leftover ETH from the deployer EOA back to a cold wallet and retire that EOA.
- Commit `broadcast/Deploy.s.sol/1/run-latest.json` (no secrets — just tx receipts).
- Record block number, tx hashes, proxy + impl addresses, and gas paid in a deployment log.

---

## Deployed addresses

| Chain | Status | Proxy address | Hot wallet |
|---|---|---|---|
| Ethereum mainnet (id 1) | Live 2026-05-18 | [`0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5`](https://etherscan.io/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) | `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256` |
| BNB Smart Chain (id 56) | Live | [`0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5`](https://bscscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) | `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256` |
| Arbitrum One (id 42161) | Live 2026-05-19 | [`0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5`](https://arbiscan.io/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) | `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256` |
| Polygon (id 137) | Live 2026-05-19 | [`0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5`](https://polygonscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) | `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256` |
| Avalanche C-Chain (id 43114) | Live 2026-05-19 | [`0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5`](https://avascan.info/blockchain/c/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5) | `0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256` |

Each chain is an independent sibling deployment — same contract bytecode and same address, but separate supply, separate role multi-sigs, and separate state. The proxy address is the one to publish in T&Cs, the Etherscan / BscScan / Arbiscan / PolygonScan / Avascan token-info forms, wallet listings, and integration docs — never the implementation address (which can change on upgrade). For Avalanche deploys note that QuickNode endpoints require the `/ext/bc/C/rpc` subpath after the auth token (e.g. `https://<name>.avalanche-mainnet.quiknode.pro/<TOKEN>/ext/bc/C/rpc`) — the other four chains serve RPC at the root.

---

## Quick checklist

- [ ] Git for Windows + Foundry installed
- [ ] `forge test` green
- [ ] Four role Safes created
- [ ] Deployer EOA funded with ~0.5 ETH
- [ ] Quicknode mainnet + Sepolia URLs in `.env`
- [ ] Etherscan API key in `.env`
- [ ] Sepolia rehearsal passed
- [ ] Mainnet dry-run gas measured
- [ ] Mainnet broadcast with `--verify --slow`
- [ ] Etherscan source verified on both proxy + impl
- [ ] Deployer drained and retired

----------------------------------------------

https://etherscan.io/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5

https://bscscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5

https://polygonscan.com/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5

https://arbiscan.io/address/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5

https://avascan.info/blockchain/c/token/0x37dAa811B668bf5d19692A7F79579B7BFaaB26A5

