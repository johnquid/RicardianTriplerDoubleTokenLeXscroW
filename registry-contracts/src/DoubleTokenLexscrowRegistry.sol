// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/// @title Double Token LeXscroW Registry
/// @notice `admin`-controlled registry contract for valid agreement factories which records duly adopted Double Token LeXscroW Agreements
/// @dev `admin` sets valid factories with approved agreement forms
contract DoubleTokenLexscrowRegistry {
    /// @notice admin address used to enable or disable factories.
    address public admin;

    /// @notice maps an address to a counter in order to support multiple adopted agreements by one address
    mapping(address => uint256) public nonce;

    /// @notice maps an address to their index of adopted agreements to the agreement details for the applicable index
    mapping(address adopter => mapping(uint256 index => address details)) public agreements;

    /// @notice A mapping which records the approved agreement factories.
    mapping(address factory => bool) public agreementFactories;

    ///
    /// EVENTS
    ///

    event DoubleTokenLexscrowRegistry_AdminUpdated(address newAdmin);

    /// @notice An event that records when an address either newly adopts the Double Token LeXscroW Agreement, or alters its previous terms.
    event DoubleTokenLexscrowRegistry_DoubleTokenLexscrowAdoption(
        address confirmingParty,
        address proposingParty,
        address details
    );

    /// @notice An event that records when an address is newly enabled as a factory.
    event DoubleTokenLexscrowRegistry_FactoryEnabled(address factory);

    /// @notice An event that records when an address is newly disabled as a factory.
    event DoubleTokenLexscrowRegistry_FactoryDisabled(address factory);

    ///
    /// ERRORS
    ///

    error DoubleTokenLexscrowRegistry_OnlyAdmin();
    error DoubleTokenLexscrowRegistry_OnlyFactories();
    error DoubleTokenLexscrowRegistry_ZeroAddress();

    /// @notice Modifier to restrict access to admin-only functions.
    modifier onlyAdmin() {
        if (msg.sender != admin) revert DoubleTokenLexscrowRegistry_OnlyAdmin();
        _;
    }

    /// @notice Sets the admin address to the provided address.
    constructor(address _admin) {
        admin = _admin;
    }

    /// @notice Officially adopt the agreement, or modify its terms if already adopted. Only callable by approved factories.
    /// @dev updates mappings for each party to the agreement
    /// @param confirmingParty address that confirmed agreement adoption
    /// @param proposingParty address that proposed the agreement i, subsequently confirmed as adopted by `confirmingParty`
    /// @param agreementDetailsAddress The new details of the agreement.
    function recordAdoption(address confirmingParty, address proposingParty, address agreementDetailsAddress) external {
        if (!agreementFactories[msg.sender]) revert DoubleTokenLexscrowRegistry_OnlyFactories();
        uint256 _confirmingPartyNonce = ++nonce[confirmingParty];
        uint256 _proposingPartyNonce = ++nonce[proposingParty];

        agreements[confirmingParty][_confirmingPartyNonce] = agreementDetailsAddress;
        agreements[proposingParty][_proposingPartyNonce] = agreementDetailsAddress;

        emit DoubleTokenLexscrowRegistry_DoubleTokenLexscrowAdoption(
            confirmingParty,
            proposingParty,
            agreementDetailsAddress
        );
    }

    /// @notice Enables an address as a factory.
    /// @param factory The address to enable.
    function enableFactory(address factory) external onlyAdmin {
        agreementFactories[factory] = true;
        emit DoubleTokenLexscrowRegistry_FactoryEnabled(factory);
    }

    /// @notice Disables an address as an factory.
    /// @param factory The address to disable.
    function disableFactory(address factory) external onlyAdmin {
        agreementFactories[factory] = false;
        emit DoubleTokenLexscrowRegistry_FactoryDisabled(factory);
    }

    /// @notice Allows the admin to transfer admin rights to another address.
    /// @param newAdmin The address of the new admin.
    function transferAdminRights(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert DoubleTokenLexscrowRegistry_ZeroAddress();
        admin = newAdmin;

        emit DoubleTokenLexscrowRegistry_AdminUpdated(newAdmin);
    }
}
