// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {DoubleTokenLexscrowRegistry} from "./DoubleTokenLexscrowRegistry.sol";
import "./SignatureValidator.sol";

/// @notice Enum that defines the inclusion of child contracts in an agreement.
enum ChildContractScope {
    // No child contracts are included
    None,
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

/// @notice Struct that contains the details of the agreement.
struct AgreementDetailsV1 {
    /// @notice The details of the parties adopting the agreement.
    Party partyA;
    Party partyB;
    /// @notice The assets and amounts being escrowed by each party.
    LockedAsset lockedAssetPartyA;
    LockedAsset lockedAssetPartyB;
    /// @notice The scope by chain.
    Chain[] chains;
    /// @notice IPFS hash of the agreement (such as an OTC sale agreement) the LeXscroW is servicing.
    string primaryAgreementURI;
    /// @notice IPFS hash of the official MetaLeX LeXscroW Agreement version being agreed to which confirms all terms.
    string LexscrowURI;
}

/// @notice Struct that contains the details of an agreement by chain.
struct Chain {
    // The accounts in scope for the agreement.
    Account[] accounts;
    // The chain ID.
    uint id;
}

/// @notice Struct that contains the details of a locked asset
struct LockedAsset {
    /// @notice token contract address
    address tokenContract;
    /// @notice total amount of `tokenContract` locked
    uint256 totalAmount;
}

/// @notice Struct that contains a party's details
struct Party {
    /// @notice The blockchain address of the party.
    address partyBlockchainAddy;
    /// @notice The name of the party adopting the agreement.
    string partyName;
    /// @notice The contact details of the party (required for pre-notifying).
    string contactDetails;
}

/// @notice Contract that contains the AgreementDetails that will be deployed by the Agreement Factory.
contract RicardianTriplerDoubleTokenLexscrow {
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
    /// @return `AgreementDetailsV1` struct containing the details of the agreement.
    function getDetails() external view returns (AgreementDetailsV1 memory) {
        return details;
    }
}

/// @notice Factory contract that creates new RicardianTriplerDoubleTokenLexscrow contracts and records their adoption in the DoubleTokenLexscrowRegistry.
/// @dev various events emitted in the `registry` contract
contract AgreementV1Factory is SignatureValidator {
    /// @notice The DoubleTokenLexscrowRegistry contract.
    DoubleTokenLexscrowRegistry public registry;

    /// @notice Constructor that sets the DoubleTokenLexscrowRegistry address.
    /// @param registryAddress The address of the DoubleTokenLexscrowRegistry contract.
    constructor(address registryAddress) {
        registry = DoubleTokenLexscrowRegistry(registryAddress);
    }

    /// @notice Function that returns the version of the agreement factory.
    function version() external pure returns (string memory) {
        return "1.0.0";
    }

    /// @notice Function that creates a new RicardianTriplerDoubleTokenLexscrow contract and records its adoption in the DoubleTokenLexscrowRegistry.
    /// @param details The details of the agreement.
    function adoptDoubleTokenLexscrowAgreement(AgreementDetailsV1 memory details) external {
        RicardianTriplerDoubleTokenLexscrow agreementDetails = new RicardianTriplerDoubleTokenLexscrow(details);
        registry.recordAdoption(msg.sender, address(agreementDetails));
    }

    function validateAccount(AgreementDetailsV1 memory details, Account memory account) external view returns (bool) {
        // Iterate over all accounts, setting signature fields to zero.
        for (uint i = 0; i < details.chains.length; i++) {
            for (uint j = 0; j < details.chains[i].accounts.length; j++) {
                details.chains[i].accounts[j].signature = new bytes(0);
            }
        }

        // Hash the details.
        bytes32 hash = keccak256(abi.encode(details));

        // Verify that the account's accountAddress signed the hashed details.
        return isSignatureValid(account.accountAddress, hash, account.signature);
    }
}
