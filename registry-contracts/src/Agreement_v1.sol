// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./SafeHarborRegistry.sol";
import "./SignatureValidator.sol";

/// @notice Contract that contains the AgreementDetails that will be deployed by the Agreement Factory.
contract AgreementV1 {
    /// @notice The details of the agreement.
    AgreementDetailsV1 private details;

    /// @notice Constructor that sets the details of the agreement.
    /// @param _details The details of the agreement.
    constructor(AgreementDetailsV1 memory _details) {
        details = _details;
    }

    /// @notice Function that returns the version of the agreement.
    function version() external pure returns (string memory) {
        return "1.0.0";
    }

    /// @notice Function that returns the details of the agreement.
    /// @dev You need a view function, else it won't convert storage to memory automatically for the nested structs.
    /// @return The details of the agreement.
    function getDetails() external view returns (AgreementDetailsV1 memory) {
        return details;
    }
}

/// @notice Factory contract that creates new AgreementV1 contracts and records their adoption in the SafeHarborRegistry.
contract AgreementV1Factory is SignatureValidator {
    /// @notice The SafeHarborRegistry contract.
    SafeHarborRegistry public registry;

    /// @notice Constructor that sets the SafeHarborRegistry address.
    /// @param registryAddress The address of the SafeHarborRegistry contract.
    constructor(address registryAddress) {
        registry = SafeHarborRegistry(registryAddress);
    }

    /// @notice Function that returns the version of the agreement factory.
    function version() external pure returns (string memory) {
        return "1.0.0";
    }

    /// @notice Function that creates a new AgreementV1 contract and records its adoption in the SafeHarborRegistry.
    /// @param details The details of the agreement.
    function adoptSafeHarbor(AgreementDetailsV1 memory details) external {
        AgreementV1 agreementDetails = new AgreementV1(details);
        registry.recordAdoption(address(agreementDetails));
    }

    function validateAccount(
        AgreementDetailsV1 memory details,
        Account memory account
    ) external view returns (bool) {
        // Iterate over all accounts, setting signature fields to zero
        for (uint i = 0; i < details.chains.length; i++) {
            for (uint j = 0; j < details.chains[i].accounts.length; j++) {
                details.chains[i].accounts[j].signature = new bytes(0);
            }
        }

        // Hash the details
        bytes32 hash = keccak256(abi.encode(details));

        // Verify that the account's accountAddress signed the hashed details
        return
            isSignatureValid(account.accountAddress, hash, account.signature);
    }
}

/// @notice Struct that contains the details of the agreement.
struct AgreementDetailsV1 {
    // The name of the protocol adopting the agreement.
    string protocolName;
    // The scope and recovery address by chain.
    Chain[] chains;
    // The contact details (required for pre-notifying).
    Contact[] contactDetails;
    // The terms of the agreement.
    BountyTerms bountyTerms;
    // Indication whether the agreement should be automatically upgraded to future versions approved by SEAL.
    bool automaticallyUpgrade;
    // IPFS hash of the actual agreement document, which confirms all terms.
    string agreementURI;
}

/// @notice Struct that contains the details of an agreement by chain.
struct Chain {
    // The accounts in scope for the agreement.
    Account[] accounts;
    // The address to which recovered assets will be sent.
    address assetRecoveryAddress;
    // The chain ID.
    uint chainID;
}

/// @notice Enum that defines the inclusion of child contracts in an agreement.
enum ChildContractScope {
    // No child contracts are included
    None,
    // Only existing child contracts are included
    ExistingOnly,
    // All child contracts, both existing and new, are included
    All
}

/// @notice Struct that contains the details of an account in an agreement.
struct Account {
    // The address of the account (EOA or smart contract).
    address accountAddress;
    // The scope of child contracts included in the agreement.
    ChildContractScope childContractScope;
    // The signature of the account. Optionally used to verify that this account has accepted this agreement.
    bytes signature;
}

/// @notice Struct that contains the contact details of the agreement.
struct Contact {
    // The name of the contact.
    string name;
    // The role of the contact.
    string role;
    // The contact details (IE email, phone, telegram).
    string contact;
}

/// @notice Enum that defines the identity requirements for a Whitehat to be eligible under the agreement.
enum IdentityRequirement {
    // The Whitehat has no moniker and no identifying information about the Whitehat has been verified.
    Anonymous,
    // The Whitehat uses a moniker but there has been limited or no verification of the legal name(s) of person(s) or entity behind the moniker.
    Pseudonymous,
    // The Whitehat is using a legal individual or entity name and that identity has been verified.
    Named
}

// @notice Struct that contains the terms of the bounty for the agreement.
struct BountyTerms {
    // Percentage of the recovered funds a Whitehat receives as their bounty (0-100).
    uint bountyPercentage;
    // The maximum bounty in USD.
    uint bountyCapUSD;
    // Indicates if the Whitehat can retain their bounty.
    bool retainable;
    // Identity requirements for Whitehats eligible under the agreement.
    IdentityRequirement identityRequirement;
    // Description of what KYC, sanctions, diligence, or other verification will be performed on Whitehats to determine their eligibility to receive the bounty.
    string diligenceRequirements;
}
