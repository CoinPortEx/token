// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test} from "forge-std/Test.sol";
import {TransparentUpgradeableProxy} from "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {CoinPortLoyaltyPoints} from "../src/CoinPortLoyaltyPoints.sol";

/// @notice Tests the CPP-specific compliance layer (closed-loop guard, freeze, complianceTransfer,
/// supply cap, role boundaries). Inherited OZ behavior (ERC20 mechanics, Permit, Pausable internals)
/// is audited upstream and not re-tested exhaustively here.
contract CoinPortLoyaltyPointsTest is Test {
    CoinPortLoyaltyPoints internal cpp;

    address internal treasury   = makeAddr("treasury");
    address internal admin      = makeAddr("admin");
    address internal pauser     = makeAddr("pauser");
    address internal minter     = makeAddr("minter");      // simulates hot wallet
    address internal compliance = makeAddr("compliance");
    address internal alice      = makeAddr("alice");
    address internal bob        = makeAddr("bob");

    uint256 internal constant LAUNCH_PROMO = 5_000_000 ether;
    uint256 internal constant MAX_SUPPLY   = 200_000_000 ether;

    function setUp() public {
        CoinPortLoyaltyPoints impl = new CoinPortLoyaltyPoints();
        bytes memory initData = abi.encodeCall(
            CoinPortLoyaltyPoints.initialize,
            (treasury, admin, pauser, minter, compliance)
        );
        TransparentUpgradeableProxy proxy = new TransparentUpgradeableProxy(
            address(impl),
            admin,
            initData
        );
        cpp = CoinPortLoyaltyPoints(address(proxy));
    }

    // ─── Initial state ────────────────────────────────────────────────────

    function test_initialState() public view {
        assertEq(cpp.name(), "CoinPort Loyalty Points");
        assertEq(cpp.symbol(), "CPP");
        assertEq(cpp.decimals(), 18);
        assertEq(cpp.totalSupply(), LAUNCH_PROMO);
        assertEq(cpp.balanceOf(treasury), LAUNCH_PROMO);
        assertFalse(cpp.transfersEnabled());

        assertTrue(cpp.hasRole(cpp.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(cpp.hasRole(cpp.PAUSER_ROLE(), pauser));
        assertTrue(cpp.hasRole(cpp.MINTER_ROLE(), minter));
        assertTrue(cpp.hasRole(cpp.COMPLIANCE_ROLE(), compliance));
        assertTrue(cpp.hasRole(cpp.HOLDER_ROLE(), treasury));
        assertTrue(cpp.hasRole(cpp.HOLDER_ROLE(), minter));

        assertEq(cpp.MAX_SUPPLY(), MAX_SUPPLY);
        assertEq(cpp.LAUNCH_PROMO_ALLOCATION(), LAUNCH_PROMO);
    }

    function test_initialize_cannotBeCalledTwice() public {
        vm.expectRevert();
        cpp.initialize(treasury, admin, pauser, minter, compliance);
    }

    // ─── Mint ─────────────────────────────────────────────────────────────

    function test_mint_byMinter_succeeds() public {
        vm.prank(minter);
        cpp.mint(minter, 1_000 ether);
        assertEq(cpp.balanceOf(minter), 1_000 ether);
        assertEq(cpp.totalSupply(), LAUNCH_PROMO + 1_000 ether);
    }

    function test_mint_byNonMinter_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                alice,
                cpp.MINTER_ROLE()
            )
        );
        vm.prank(alice);
        cpp.mint(alice, 1_000 ether);
    }

    function test_mint_uptoCap_succeeds() public {
        uint256 remaining = MAX_SUPPLY - LAUNCH_PROMO;
        vm.prank(minter);
        cpp.mint(minter, remaining);
        assertEq(cpp.totalSupply(), MAX_SUPPLY);
    }

    function test_mint_overCap_reverts() public {
        uint256 remaining = MAX_SUPPLY - LAUNCH_PROMO;
        vm.prank(minter);
        vm.expectRevert("CPP: max supply exceeded");
        cpp.mint(minter, remaining + 1);
    }

    function testFuzz_mint_respectsCap(uint256 amount) public {
        amount = bound(amount, 0, type(uint256).max - LAUNCH_PROMO);
        vm.prank(minter);
        if (amount + LAUNCH_PROMO > MAX_SUPPLY) {
            vm.expectRevert("CPP: max supply exceeded");
            cpp.mint(minter, amount);
        } else {
            cpp.mint(minter, amount);
            assertEq(cpp.totalSupply(), LAUNCH_PROMO + amount);
        }
    }

    // ─── Closed-loop transfer guard ───────────────────────────────────────

    function test_transfer_holderToHolder_succeeds() public {
        vm.prank(treasury);
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(minter, 1_000 ether);
        assertEq(cpp.balanceOf(minter), 1_000 ether);
        assertEq(cpp.balanceOf(treasury), LAUNCH_PROMO - 1_000 ether);
    }

    /* DISABLED while the closed-loop guard is commented out in src/CoinPortLoyaltyPoints.sol.
       Uncomment together with that guard.

    function test_transfer_holderToNonHolder_reverts() public {
        vm.prank(treasury);
        vm.expectRevert("CPP: closed-loop, transfer not authorized");
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(alice, 100 ether);
    }

    function test_transfer_nonHolderToHolder_reverts() public {
        // Seed alice via complianceTransfer (the only way to get tokens to a non-holder)
        vm.prank(compliance);
        cpp.complianceTransfer(treasury, alice, 1_000 ether);

        vm.prank(alice);
        vm.expectRevert("CPP: closed-loop, transfer not authorized");
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(treasury, 100 ether);
    }

    function test_transfer_nonHolderToNonHolder_reverts() public {
        vm.prank(compliance);
        cpp.complianceTransfer(treasury, alice, 1_000 ether);

        vm.prank(alice);
        vm.expectRevert("CPP: closed-loop, transfer not authorized");
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(bob, 100 ether);
    }

    function test_transferFrom_nonHolderPath_reverts() public {
        vm.prank(compliance);
        cpp.complianceTransfer(treasury, alice, 1_000 ether);

        vm.prank(alice);
        cpp.approve(bob, 100 ether);

        vm.prank(bob);
        vm.expectRevert("CPP: closed-loop, transfer not authorized");
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transferFrom(alice, bob, 100 ether);
    }

    */

    // ─── Burn ─────────────────────────────────────────────────────────────

    function test_burn_byHolder_succeeds() public {
        // Simulates redemption flow: hot wallet self-burns
        vm.prank(minter);
        cpp.mint(minter, 1_000 ether);

        vm.prank(minter);
        cpp.burn(500 ether);

        assertEq(cpp.balanceOf(minter), 500 ether);
        assertEq(cpp.totalSupply(), LAUNCH_PROMO + 500 ether);
    }

    function test_burn_whenSenderFrozen_reverts() public {
        vm.prank(compliance);
        cpp.freeze(treasury);

        vm.prank(treasury);
        vm.expectRevert("CPP: sender frozen");
        cpp.burn(100 ether);
    }

    // ─── Pause ────────────────────────────────────────────────────────────

    function test_pause_blocksTransfers() public {
        vm.prank(pauser);
        cpp.pause();

        vm.prank(treasury);
        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(minter, 1_000 ether);
    }

    function test_pause_byNonPauser_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                alice,
                cpp.PAUSER_ROLE()
            )
        );
        vm.prank(alice);
        cpp.pause();
    }

    function test_unpause_resumesTransfers() public {
        vm.prank(pauser);
        cpp.pause();
        vm.prank(pauser);
        cpp.unpause();

        vm.prank(treasury);
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(minter, 1_000 ether);
        assertEq(cpp.balanceOf(minter), 1_000 ether);
    }

    // ─── Freeze ───────────────────────────────────────────────────────────

    function test_freeze_byCompliance_succeeds() public {
        vm.prank(compliance);
        cpp.freeze(treasury);
        assertTrue(cpp.isFrozen(treasury));
    }

    function test_freeze_byNonCompliance_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                alice,
                cpp.COMPLIANCE_ROLE()
            )
        );
        vm.prank(alice);
        cpp.freeze(treasury);
    }

    function test_freeze_blocksFrozenSender() public {
        vm.prank(compliance);
        cpp.freeze(treasury);

        vm.prank(treasury);
        vm.expectRevert("CPP: sender frozen");
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(minter, 100 ether);
    }

    function test_freeze_blocksFrozenRecipient() public {
        vm.prank(compliance);
        cpp.freeze(minter);

        vm.prank(treasury);
        vm.expectRevert("CPP: recipient frozen");
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(minter, 100 ether);
    }

    function test_freeze_blocksMintToFrozen() public {
        vm.prank(compliance);
        cpp.freeze(minter);

        vm.prank(minter);
        vm.expectRevert("CPP: recipient frozen");
        cpp.mint(minter, 100 ether);
    }

    function test_unfreeze_restoresTransfer() public {
        vm.prank(compliance);
        cpp.freeze(treasury);

        vm.prank(compliance);
        cpp.unfreeze(treasury);

        vm.prank(treasury);
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(minter, 100 ether);
        assertEq(cpp.balanceOf(minter), 100 ether);
    }

    // ─── complianceTransfer ───────────────────────────────────────────────

    function test_complianceTransfer_bypassesFreeze() public {
        vm.prank(compliance);
        cpp.freeze(treasury);

        // Compliance can still move tokens out of frozen treasury (sanctions enforcement / court order)
        vm.prank(compliance);
        cpp.complianceTransfer(treasury, minter, 1_000 ether);

        assertEq(cpp.balanceOf(minter), 1_000 ether);
    }

    function test_complianceTransfer_bypassesClosedLoop() public {
        vm.prank(compliance);
        cpp.complianceTransfer(treasury, alice, 1_000 ether);
        assertEq(cpp.balanceOf(alice), 1_000 ether);

        // alice and bob both lack HOLDER_ROLE — only complianceTransfer can move between them
        vm.prank(compliance);
        cpp.complianceTransfer(alice, bob, 500 ether);
        assertEq(cpp.balanceOf(bob), 500 ether);
    }

    function test_complianceTransfer_byNonCompliance_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                alice,
                cpp.COMPLIANCE_ROLE()
            )
        );
        vm.prank(alice);
        cpp.complianceTransfer(treasury, alice, 1_000 ether);
    }

    // ─── setTransfersEnabled (Model A escape hatch) ──────────────────────

    function test_setTransfersEnabled_byAdmin_succeeds() public {
        vm.prank(admin);
        cpp.setTransfersEnabled(true);
        assertTrue(cpp.transfersEnabled());
    }

    /* DISABLED while the closed-loop guard is commented out in src/CoinPortLoyaltyPoints.sol.
       Uncomment together with that guard.

    function test_setTransfersEnabled_allowsOpenTransfers() public {
        vm.prank(compliance);
        cpp.complianceTransfer(treasury, alice, 1_000 ether);

        vm.prank(alice);
        vm.expectRevert("CPP: closed-loop, transfer not authorized");
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(bob, 100 ether);

        vm.prank(admin);
        cpp.setTransfersEnabled(true);

        vm.prank(alice);
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        cpp.transfer(bob, 100 ether);
        assertEq(cpp.balanceOf(bob), 100 ether);
    }

    */

    function test_setTransfersEnabled_byNonAdmin_reverts() public {
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector,
                alice,
                cpp.DEFAULT_ADMIN_ROLE()
            )
        );
        vm.prank(alice);
        cpp.setTransfersEnabled(true);
    }
}
