// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {CoinPortLoyaltyPoints} from "../src/CoinPortLoyaltyPoints.sol";

/// @notice Deploys CoinPortLoyaltyPoints behind a TransparentUpgradeableProxy.
///
/// Usage (Sepolia testnet rehearsal first, then mainnet):
///     source .env
///     forge script script/Deploy.s.sol:DeployCPP \
///         --rpc-url $SEPOLIA_RPC_URL \
///         --private-key $PRIVATE_KEY \
///         --broadcast \
///         --verify
///
/// For Ethereum L1 mainnet, swap $SEPOLIA_RPC_URL for $MAINNET_RPC_URL.
///
/// Required env vars (see .env.example):
///     CPP_TREASURY_ADDRESS, CPP_ADMIN_ADDRESS, CPP_PAUSER_ADDRESS,
///     CPP_MINTER_ADDRESS, CPP_COMPLIANCE_ADDRESS
contract DeployCPP is Script {
    /// Documented hot wallet from project memory. Deployment warns if minter doesn't match.
    address constant DOCUMENTED_HOT_WALLET = 0xfcE919e9A781b66b3Cf91A9F021aE2eF104D9256;

    function run() external returns (address proxyAddr, address implAddr) {
        address treasury          = vm.envAddress("CPP_TREASURY_ADDRESS");
        address defaultAdmin      = vm.envAddress("CPP_ADMIN_ADDRESS");
        address pauser            = vm.envAddress("CPP_PAUSER_ADDRESS");
        address minter            = vm.envAddress("CPP_MINTER_ADDRESS");
        address complianceOfficer = vm.envAddress("CPP_COMPLIANCE_ADDRESS");

        // ─── Sanity checks ────────────────────────────────────────────────
        require(treasury          != address(0), "CPP_TREASURY_ADDRESS unset");
        require(defaultAdmin      != address(0), "CPP_ADMIN_ADDRESS unset");
        require(pauser            != address(0), "CPP_PAUSER_ADDRESS unset");
        require(minter            != address(0), "CPP_MINTER_ADDRESS unset");
        require(complianceOfficer != address(0), "CPP_COMPLIANCE_ADDRESS unset");

        // Model B custody separation: cold treasury must not equal hot wallet
        require(treasury != minter, "Treasury must differ from hot wallet (Model B)");
        require(defaultAdmin != minter, "Admin must differ from hot wallet (role separation)");

        if (minter != DOCUMENTED_HOT_WALLET) {
            console2.log("WARNING: minter does not match documented hot wallet");
            console2.log("  expected:", DOCUMENTED_HOT_WALLET);
            console2.log("  got:     ", minter);
        }

        bytes memory initData = abi.encodeCall(
            CoinPortLoyaltyPoints.initialize,
            (treasury, defaultAdmin, pauser, minter, complianceOfficer)
        );

        // ─── Deploy ────────────────────────────────────────────────────────
        vm.startBroadcast();

        CoinPortLoyaltyPoints impl = new CoinPortLoyaltyPoints();
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(impl),
            defaultAdmin,    // initial owner of the auto-deployed ProxyAdmin
            initData
        );

        vm.stopBroadcast();

        proxyAddr = address(proxy);
        implAddr  = address(impl);

        // ─── Log ───────────────────────────────────────────────────────────
        console2.log("");
        console2.log("=== CoinPortLoyaltyPoints deployed ===");
        console2.log("  Proxy:          ", proxyAddr);
        console2.log("  Implementation: ", implAddr);
        console2.log("");
        console2.log("Roles granted via initialize():");
        console2.log("  DEFAULT_ADMIN_ROLE  ->", defaultAdmin);
        console2.log("  PAUSER_ROLE         ->", pauser);
        console2.log("  MINTER_ROLE         ->", minter);
        console2.log("  COMPLIANCE_ROLE     ->", complianceOfficer);
        console2.log("  HOLDER_ROLE         ->", treasury, "(treasury)");
        console2.log("  HOLDER_ROLE         ->", minter, "(hot wallet)");
        console2.log("");
        console2.log("Premint: 5,000,000 CPP -> treasury");
        console2.log("Hard supply cap: 200,000,000 CPP");
        console2.log("transfersEnabled = false (closed-loop)");
        console2.log("");
        console2.log("ProxyAdmin owner:", defaultAdmin, "(controls future upgrades)");
        console2.log("");
        console2.log("Post-deploy verification checklist:");
        console2.log("  - balanceOf(treasury) == 5,000,000e18");
        console2.log("  - totalSupply() == 5,000,000e18");
        console2.log("  - transfersEnabled() == false");
        console2.log("  - All five role grants confirmed via hasRole()");
    }
}
