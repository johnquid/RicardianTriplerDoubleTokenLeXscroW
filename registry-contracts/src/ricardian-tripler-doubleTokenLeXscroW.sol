// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./doubleTokenLeXscroWRegistry.sol";
import "./SignatureValidator.sol";

/// @notice Contract that contains the AgreementDetails that will be deployed by the Agreement Factory.
contract ricardian-tripler-doubleTokenLeXscroW {
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
        registry.recordAdoption(msg.sender, address(agreementDetails));
    }

    function validateAccount(
        AgreementDetailsV1 memory details,
        Account memory account
    ) external view returns (bool) {
        // Iterate over all accounts, setting signature fields to zero.
        for (uint i = 0; i < details.chains.length; i++) {
            for (uint j = 0; j < details.chains[i].accounts.length; j++) {
                details.chains[i].accounts[j].signature = new bytes(0);
            }
        }

        // Hash the details.
        bytes32 hash = keccak256(abi.encode(details));

        // Verify that the account's accountAddress signed the hashed details.
        return
            isSignatureValid(account.accountAddress, hash, account.signature);
    }
}

/// @notice Struct that contains the details of the agreement.
struct AgreementDetailsV1 {
    // The names of the parties adopting the agreement.
    string partyAName;
    string partyBName;
    // The contact details of each party (required for pre-notifying).
    string contactDetailspartyA;
    string contactDetailspartyB;
    // The blockchain addresses of each party.
    string blockchainAddypartyA;
    string blockchainAddypartyB;
    // The assets being escrowed by each party.
    LockedAsset lockedAssetPartyA;
    LockedAsset lockedAssetPartyB;
    // IPFS hash of the agreement (such as an OTC sale agreement) the LeXscroW is servicing.
    string primaryAgreementURI;
    // IPFS hash of the official MetaLeX LeXscroW Agreement version being agreed to which confirms all terms.
    string LeXscroWURI;
}



/// @notice Struct that contains the details of a locked asset
struct LockedAsset {
    // details to come
}



