// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "./SignatureValidator.sol";
import "./Mediate.sol"

interface IDoubleTokenLexscrowFactory {
    function deployDoubleTokenLexscrow(
        bool openOffer,
        uint256 totalAmount1,
        uint256 totalAmount2,
        uint256 expirationTime,
        address agent,
        address principal,
        address tokenContract1,
        address tokenContract2,
        address receipt,
        Condition[] calldata _conditions
    ) external;
}

interface IDoubleTokenLexscrowRegistry {
    function recordAdoption(address confirmingParty, address proposingParty, address agreementDetailsAddress) external;
}

///
/// STRUCTS AND TYPES
///

enum Logic {
    AND,
    OR
}

/// @notice the details of an account in an agreement
struct Account {
    // The address of the account (EOA or smart contract)
    address accountAddress;
    // The signature of the account. Optionally used to verify that this account has signed hashed agreement details
    bytes signature;
}

/// @notice the details of the agreement, consisting of all necessary information to deploy a DoubleTokenLexscrow and the legal agreement information
struct AgreementDetailsV1 {
    /// @notice The details of the parties adopting the agreement
    Party partyA;
    Party partyB;
    /// @notice The assets and amounts being escrowed by each party
    LockedAsset lockedAssetPartyA;
    LockedAsset lockedAssetPartyB;
    /// @notice block.timestamp expiration time
    uint256 expirationTime;
    /// @notice optional contract to return an informational receipt of a `LockedAsset` value, otherwise address(0)
    address receipt;
    /// @notice IPFS hash of the official MetaLeX LeXscroW Agreement version being agreed to which confirms all terms, and may contain a unique interface identifier
    string legalAgreementURI;
    /// @notice governing law for the Agreement
    string governingLaw;
    // @notice dispute resolution elected by the parties (initially empty)
    Dispute[] disputes; 
    /// @notice array of `Condition` structs upon which the DoubleTokenLexscrow is contingent
    /// (that must be done to accept the offer, and be bound by, or bonded to, the agreement)
    Condition[] conditions;
    
}

/// @notice match `Condition` as defined in LexscrowConditionManager
struct Condition {
    address condition;
    Logic op;
}

/// @notice the details of a locked asset
struct LockedAsset {
    /// @notice token contract address (`tokenContract1` or `tokenContract2`)
    address tokenContract;
    /// @notice total amount of `tokenContract` locked
    uint256 totalAmount;
}

/// @notice details of a party (`partyB` or `partyA`): address, name, and contact information
struct Party {
    /// @notice The blockchain address of the party
    address partyBlockchainAddy;
    /// @notice The name of the party adopting the agreement
    string partyName;
    /// @notice The contact details of the party (required for legal notifications under the agreement)
    string contactDetails;
}

///
/// CONTRACTS
///

/// @notice Contract that contains the Double Token LeXscroW agreement details that will be deployed by the Agreement Factory.
contract RicardianTriplerDoubleTokenLexscrow {
    uint256 internal constant AGREEMENT_VERSION = 1;

    /// @notice The details of the agreement; accessible via `getDetails`
    AgreementDetailsV1 internal details;

    /// @notice Constructor that sets the details of the agreement.
    /// @param _details the `AgreementDetailsV1` struct containing the details of the agreement.
    constructor(AgreementDetailsV1 memory _details) {
        details.partyA = _details.partyA;
        details.partyB = _details.partyB;
        details.lockedAssetPartyA = _details.lockedAssetPartyA;
        details.lockedAssetPartyB = _details.lockedAssetPartyB;
        details.expirationTime = _details.expirationTime;
        details.receipt = _details.receipt;
        details.legalAgreementURI = _details.legalAgreementURI;
        details.governingLaw = _details.governingLaw;
        details.disputeResolutionMethod = _details.disputeResolutionMethod;

        // necessary for copying dynamic array of structs to storage
        for (uint256 i = 0; i < _details.conditions.length; ) {
            details.conditions.push(_details.conditions[i]);
            unchecked {
                ++i; // cannot overflow without hitting gaslimit
            }
        }
    }



    // All parties agree to reassignment of a party
    function novation() external {

    }


    function recision() external {

    }

    // creates a dispute
    function injunction() external {

    }

    /// @notice Function that returns the version of the agreement.
    function version() external pure returns (uint256) {
        return AGREEMENT_VERSION;
    }

    /// @notice Function that returns the details of the agreement.
    /// @dev view function necessary to convert storage to memory automatically for the nested structs.
    /// @return `AgreementDetailsV1` struct containing the details of the agreement.
    function getDetails() external view returns (AgreementDetailsV1 memory) {
        return details;
    }
}

/// @notice Factory contract that creates new RicardianTriplerDoubleTokenLexscrow contracts if confirmed properly by both parties
/// and records their adoption in the DoubleTokenLexscrowRegistry. Either party may propose the agreement adoption, for the other to confirm.
/// Also contains an option to deploy a Double Token LeXscroW simultaneously with proposing an agreement to ensure the parameters are identical.
/// @dev various events emitted in the `registry` contract
contract AgreementV1Factory is SignatureValidator {
    uint256 internal constant FACTORY_VERSION = 1;

    /// @notice The DoubleTokenLexscrowRegistry contract.
    address public registry;

    /// @notice address of proposer of an agreement mapped to the pending agreement address, mapped to the second party address that must confirm adoption
    mapping(address proposer => mapping(address pendingAgreement => address pendingParty)) public pendingAgreement;

    /// @notice hashed agreement details mapped to whether they match a pending agreement
    mapping(bytes32 => bool) public pendingAgreementHash;

    error RicardianTriplerDoubleTokenLexscrow_NoPendingAgreement();
    error RicardianTriplerDoubleTokenLexscrow_NotParty();

    /// @notice event that fires if an address party to a DoubleTokenLeXscroW proposes a new RicardianTriplerDoubleTokenLexscrow contract
    event RicardianTriplerDoubleTokenLexscrow_Proposed(address proposer, address pendingAgreementAddress);

    /// @notice Constructor that sets the DoubleTokenLexscrowRegistry address.
    /// @dev no access control necessary as valid factories are set by the `admin` in the `registry` contract
    /// @param registryAddress The address of the DoubleTokenLexscrowRegistry contract.
    constructor(address registryAddress) {
        registry = registryAddress;
    }

    /// @notice for a party to a DoubleTokenLeXscroW to propose a new RicardianTriplerDoubleTokenLexscrow contract, which will be adopted if confirmed by the
    /// other party to the DoubleTokenLeXscroW.
    /// @param details The details of the proposed agreement, as an `AgreementDetailsV1` struct
    /// @return _agreementAddress address of the pending `RicardianTriplerDoubleTokenLexscrow` agreement
    function proposeDoubleTokenLexscrowAgreement(AgreementDetailsV1 calldata details) external returns (address) {
        RicardianTriplerDoubleTokenLexscrow agreementDetails = new RicardianTriplerDoubleTokenLexscrow(details);
        address _agreementAddress = address(agreementDetails);

        // if msg.sender is `partyA`, nested map it to the pending agreement to the address that needs to confirm adoption, and vice versa if `partyB`; else, revert
        if (msg.sender == details.partyA.partyBlockchainAddy)
            pendingAgreement[msg.sender][_agreementAddress] = details.partyB.partyBlockchainAddy;
        else if (msg.sender == details.partyB.partyBlockchainAddy)
            pendingAgreement[msg.sender][_agreementAddress] = details.partyA.partyBlockchainAddy;
        else revert RicardianTriplerDoubleTokenLexscrow_NotParty();

        pendingAgreementHash[keccak256(abi.encode(details))] = true;

        emit RicardianTriplerDoubleTokenLexscrow_Proposed(msg.sender, _agreementAddress);
        return (_agreementAddress);
    }

    /// @notice for a party to an intended DoubleTokenLexscrow to (1) deploy the DoubleTokenLexscrow and
    /// (2) propose a new RicardianTriplerDoubleTokenLexscrow contract, which will be adopted if confirmed by the
    /// other party to the DoubleTokenLeXscroW.
    /// @dev all of the deployment conditionals and checks for a DoubleTokenLexscrow are housed in `DoubleTokenLexscrow.sol`, so no need to duplicate here
    /// @param details The details of the proposed DoubleTokenLexscrow and agreement, as an `AgreementDetailsV1` struct
    /// @param _doubleTokenLexscrowFactory contract address of the DoubleTokenLexscrowFactory.sol which will be used to deploy a DoubleTokenLexscrow
    /// @return _agreementAddress address of the pending `RicardianTriplerDoubleTokenLexscrow` agreement
    function deployLexscrowAndProposeDoubleTokenLexscrowAgreement(
        AgreementDetailsV1 calldata details,
        address _doubleTokenLexscrowFactory
    ) external returns (address) {
        IDoubleTokenLexscrowFactory(_doubleTokenLexscrowFactory).deployDoubleTokenLexscrow(
            false, // `partyA` must be identified-- cannot be an `openOffer`
            details.lockedAssetPartyA.totalAmount, // `totalAmount1`
            details.lockedAssetPartyB.totalAmount, // `totalAmount2`
            details.expirationTime,
            details.partyB.partyBlockchainAddy, // `partyB`, corresponding to `agent` in the Double Token LeXscroW, locking `lockedAssetPartyB`
            details.partyA.partyBlockchainAddy, // `partyA`, corresponding to `principal` in the Double Token LeXscroW, locking `lockedAssetPartyA`
            details.lockedAssetPartyA.tokenContract, // `totalContract1`
            details.lockedAssetPartyB.tokenContract, // `totalContract2`
            details.receipt,
            details.conditions
        );

        RicardianTriplerDoubleTokenLexscrow agreementDetails = new RicardianTriplerDoubleTokenLexscrow(details);
        address _agreementAddress = address(agreementDetails);

        // if msg.sender is `partyA`, nested map it to the pending agreement to the address that needs to confirm adoption, and vice versa if `partyB`; else, revert
        if (msg.sender == details.partyA.partyBlockchainAddy)
            pendingAgreement[msg.sender][_agreementAddress] = details.partyB.partyBlockchainAddy;
        else if (msg.sender == details.partyB.partyBlockchainAddy)
            pendingAgreement[msg.sender][_agreementAddress] = details.partyA.partyBlockchainAddy;
        else revert RicardianTriplerDoubleTokenLexscrow_NotParty();

        pendingAgreementHash[keccak256(abi.encode(details))] = true;

        emit RicardianTriplerDoubleTokenLexscrow_Proposed(msg.sender, _agreementAddress);
        return (_agreementAddress);
    }

    /// @notice creates a new RicardianTriplerDoubleTokenLexscrow contract and records its adoption in the DoubleTokenLexscrowRegistry if called by the second party to `details`;
    /// i.e. the party address that did not initiate the adoption by calling `proposeDoubleTokenLexscrowAgreement`
    /// @param pendingAgreementAddress the address of the pending agreement being confirmed
    /// @param proposingParty the address of the party that initially proposed the pending Agreement
    /// @param details `AgreementDetailsV1` struct of the agreement details which will be hashed to ensure same parameters as the proposed agreement
    function confirmAndAdoptDoubleTokenLexscrowAgreement(
        address pendingAgreementAddress,
        address proposingParty,
        AgreementDetailsV1 calldata details
    ) external {
        bytes32 pendingHash = keccak256(abi.encode(details));
        if (
            pendingAgreement[proposingParty][pendingAgreementAddress] != msg.sender ||
            !pendingAgreementHash[pendingHash]
        ) revert RicardianTriplerDoubleTokenLexscrow_NoPendingAgreement();

        delete pendingAgreement[proposingParty][pendingAgreementAddress];
        delete pendingAgreementHash[pendingHash];

        IDoubleTokenLexscrowRegistry(registry).recordAdoption(msg.sender, proposingParty, pendingAgreementAddress);
    }

    /// @notice validate that an `account` has signed the hashed agreement details
    /// @param details `AgreementDetailsV1` struct of the agreement details to which `account` is being validated as signed
    /// @param account `Account` struct of the account which is being validated as having signed `details`
    function validateAccount(AgreementDetailsV1 calldata details, Account memory account) external view returns (bool) {
        bytes32 hash = keccak256(abi.encode(details));

        // Verify that the account's accountAddress signed the hashed details.
        return isSignatureValid(account.accountAddress, hash, account.signature);
    }

    /// @notice Function that returns the version of the agreement factory.
    function version() external pure returns (uint256) {
        return FACTORY_VERSION;
    }
}
