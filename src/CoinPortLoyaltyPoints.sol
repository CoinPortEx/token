// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.6.0
pragma solidity ^0.8.28;

import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {ERC20BurnableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {ERC20PermitUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

/// @custom:security-contact token@coinport.exchange
contract CoinPortLoyaltyPoints is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PausableUpgradeable,
    AccessControlUpgradeable,
    ERC20PermitUpgradeable
{
    // ─── Roles: OZ Wizard scaffold ───────────────────────────────────────
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    // ─── Roles: CPP compliance layer ─────────────────────────────────────
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");
    bytes32 public constant HOLDER_ROLE = keccak256("HOLDER_ROLE");

    // ─── Supply caps (earning.md §5) ─────────────────────────────────────
    uint256 public constant MAX_SUPPLY = 200_000_000 * 10 ** 18;
    uint256 public constant LAUNCH_PROMO_ALLOCATION = 5_000_000 * 10 ** 18;

    // ─── Closed-loop state (Model B: custodial) ──────────────────────────
    // transfersEnabled stays false under Model B. Admin may flip later if a
    // Model A migration is ever undertaken (separate legal review required).
    bool public transfersEnabled;
    mapping(address => bool) public isFrozen;

    // ─── Events: compliance audit trail ──────────────────────────────────
    event TransfersEnabledChanged(bool enabled);
    event AddressFrozen(address indexed account);
    event AddressUnfrozen(address indexed account);
    event ComplianceTransfer(
        address indexed from,
        address indexed to,
        uint256 value,
        address indexed officer
    );

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Deploy-time initialization. All addresses must be set at deployment.
    /// @param treasury Cold multi-sig that receives the 5M launch promo allocation and holds HOLDER_ROLE.
    /// @param defaultAdmin Cold multi-sig with role-management authority (DEFAULT_ADMIN_ROLE).
    /// @param pauser Multi-sig with PAUSER_ROLE.
    /// @param minter Hot wallet (loyalty engine) with MINTER_ROLE and HOLDER_ROLE — destination for all minted CPP.
    /// @param complianceOfficer Multi-sig with COMPLIANCE_ROLE (freeze/unfreeze/complianceTransfer).
    function initialize(
        address treasury,
        address defaultAdmin,
        address pauser,
        address minter,
        address complianceOfficer
    ) public initializer {
        __ERC20_init("CoinPort Loyalty Points", "CPP");
        __ERC20Burnable_init();
        __ERC20Pausable_init();
        __AccessControl_init();
        __ERC20Permit_init("CoinPort Loyalty Points");

        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(PAUSER_ROLE, pauser);
        _grantRole(MINTER_ROLE, minter);
        _grantRole(COMPLIANCE_ROLE, complianceOfficer);

        // Authorized holders under closed-loop: cold treasury + hot wallet.
        // Any future authorized holder must be granted HOLDER_ROLE by DEFAULT_ADMIN_ROLE.
        _grantRole(HOLDER_ROLE, treasury);
        _grantRole(HOLDER_ROLE, minter);

        // Launch promotion allocation (earning.md §5)
        _mint(treasury, LAUNCH_PROMO_ALLOCATION);
    }

    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= MAX_SUPPLY, "CPP: max supply exceeded");
        _mint(to, amount);
    }

    // ─── Compliance admin functions ──────────────────────────────────────

    /// @notice Toggle the closed-loop guard. Default is false (closed-loop). Flipping to
    /// true allows non-mint/non-burn transfers between any two non-frozen addresses, which
    /// changes the legal posture under compliance.md — DO NOT enable without fresh legal review.
    function setTransfersEnabled(bool enabled) external onlyRole(DEFAULT_ADMIN_ROLE) {
        transfersEnabled = enabled;
        emit TransfersEnabledChanged(enabled);
    }

    function freeze(address account) external onlyRole(COMPLIANCE_ROLE) {
        isFrozen[account] = true;
        emit AddressFrozen(account);
    }

    function unfreeze(address account) external onlyRole(COMPLIANCE_ROLE) {
        isFrozen[account] = false;
        emit AddressUnfrozen(account);
    }

    /// @notice Forced transfer for court orders, sanctions enforcement, or error correction.
    /// Bypasses freeze and closed-loop checks. Pause is NOT bypassed — admin must unpause first if needed.
    function complianceTransfer(address from, address to, uint256 value)
        external
        onlyRole(COMPLIANCE_ROLE)
    {
        emit ComplianceTransfer(from, to, value, _msgSender());
        _transfer(from, to, value);
    }

    // ─── Overrides ───────────────────────────────────────────────────────

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20PausableUpgradeable)
    {
        // ─── Closed-loop transfer guard: TEMPORARILY DISABLED ───────────
        // Disabled for internal blockchain testing. Re-enable by uncommenting
        // the `isMint`/`isBurn` declarations and the inner `if` block below
        // to restore HOLDER_ROLE-gated transfers. The HOLDER_ROLE,
        // transfersEnabled flag, and setTransfersEnabled() are left in
        // place so re-enablement is a comment-toggle, not a redeploy of
        // missing infrastructure.
        // bool isMint = from == address(0);
        // bool isBurn = to == address(0);
        bool isComplianceAction = hasRole(COMPLIANCE_ROLE, _msgSender());

        if (!isComplianceAction) {
            require(!isFrozen[from], "CPP: sender frozen");
            require(!isFrozen[to], "CPP: recipient frozen");

            // if (!isMint && !isBurn && !transfersEnabled) {
            //     require(
            //         hasRole(HOLDER_ROLE, from) && hasRole(HOLDER_ROLE, to),
            //         "CPP: closed-loop, transfer not authorized"
            //     );
            // }
        }

        super._update(from, to, value);
    }
}
