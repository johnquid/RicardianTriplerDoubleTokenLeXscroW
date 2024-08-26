# Double Token LeXscroW Registry

This directory houses smart contracts written in Solidity which serve three main purposes:

1. Allow parties to a Double Token LeXscroW to officially adopt the form agreement with their chosen governing law and dispute resolution.
2. Store the agreement details on-chain for ease-of-use and persistent credibly neutral storage.
3. Allow for future agreement versions and adoptions without affecting prior agreements.

# Technical Details

This repository is built using [Foundry](https://book.getfoundry.sh/). See the installation instructions [here](https://github.com/foundry-rs/foundry#installation). To test the contracts, use `forge test`.

Contracts in this system:

-   `DoubleTokenLexscrowRegistry` - Where adopted agreement addresses are stored, new agreements are registered, and agreement factories are enabled / disabled.
-   `AgreementV1Factory` within `RicardianTriplerDoubleTokenLexscrow` - Where parties adopt new agreement contracts.
-   `RicardianTriplerDoubleTokenLexscrow` - Adopted agreements proposed by a party and confirmed by the other party to a Double Token LeXscroW.
-   `SignatureValidator` - Used to determine whether a hash was validly signed by an address

## Setup

1. The `DoubleTokenLexscrowRegistry` contract is deployed with the admin passed as a constructor argument.
2. The `AgreementV1Factory` contract is deployed with the `DoubleTokenLexscrowRegistry` address passed as a constructor argument.
3. The `DoubleTokenLexscrowRegistry` admin calls `enableFactory()` on `DoubleTokenLexscrowRegistry` with the `AgreementV1Factory`'s address.

In the future MetaLeX may create new versions of this agreement. When this happens a new factory (e.g. `AgreementV2Factory`) may be deployed and enabled using the `enableFactory()` method. Optionally, the admin may disable old factories to prevent new adoptions using old agreement structures.

## Adoption

1.  A party to a Double Token LeXscroW calls `proposeDoubleTokenLexscrowAgreement()` on an `AgreementFactory` with their `AgreementDetails`. To deploy a Double Token LeXscroW and propose an agreement simultaneously, a party calls `deployLexscrowAndProposeDoubleTokenLexscrowAgreement()` with the same parameters included in the passed `AgreementDetails` and the applicable contract address of the `DoubleTokenLexscrowFactory` which will be used to deploy the Double Token LeXscroW.
2.  The factory creates an `RicardianTriplerDoubleTokenLexscrow` contract containing the provided agreement details.
3.  The other party to the applicable Double Token LeXscroW calls `confirmAndAdoptDoubleTokenLexscrowAgreement()` with identical `AgreementDetails`, the pending agreement's contract address, and the address of initial proposing party to confirm adoption.
4.  The factory adds the `RicardianTriplerDoubleTokenLexscrow` contract address to the `DoubleTokenLexscrowRegistry`.

Calling `confirmAndAdoptDoubleTokenLexscrowAgreement()` operates as a legally binding countersignature to the agreement, binding the two parties to the agreement.

### Signed Accounts

For added security, parties may choose to sign their agreement for the scoped accounts. Both EOA and ERC-1271 signatures are supported and can be validated with the agreement's factory. 

#### Signing the Agreement Details

When preparing the final agreement details, prior to deploying on-chain, the parties may sign the agreement details for any or all of the accounts under scope and store these signatures within the agreement details. A helper script to generate these account signatures for EOA accounts has been provided. To use it set the `SIGNER_PRIVATE_KEY` environment variable. Then, run the script using:

```
forge script GenerateAccountSignatureV1.s.sol --fork-url <YOUR_RPC_URL> -vvvv
```

#### Verification of Signed Accounts

Parties may use the agreement factory's `validateAccount()` method to verify that a given Account has consented to the agreement details.

## Querying Agreements

1. Query the `agreements` nested mapping in the `DoubleTokenLexscrowRegistry` contract (via the getter) a party's address and their index to get the protocol's `RicardianTriplerDoubleTokenLexscrow` address. This information is also emitted in the `DoubleTokenLexscrowRegistry_DoubleTokenLexscrowAdoption` event when `recordAdoption()` is called. To check if a `RicardianTriplerDoubleTokenLexscrow` was properly signed and recorded, a user may pass its address to the `signedAgreement` mapping in the `DoubleTokenLexscrowRegistry`; if it returns `true`, it was mutually signed and recorded.
2. Query the `RicardianTriplerDoubleTokenLexscrow` contract with `getDetails()` to get the structured agreement details.

Different versions may have different `AgreementDetails` structs. All `RicardianTriplerDoubleTokenLexscrow` and `AgreementFactory` contracts will include a `version()` method that can be used to infer the `AgreementDetails` structure.

# Deployment

The Double Token LeXscroW Registry will be deployed using the deterministic deployment proxy described here: https://github.com/Arachnid/deterministic-deployment-proxy, which is built into Foundry by default.

To deploy the registry to an EVM-compatible chain where it is not currently deployed:

1. Ensure the deterministic-deployment-proxy is deployed at 0x4e59b44847b379578588920cA78FbF26c0B4956C, and if it's not, deploy it using [the process mentioned above](https://github.com/Arachnid/deterministic-deployment-proxy).
2. Deploy the registry using the above proxy with salt `bytes32(0)` from the EOA that will become the registry admin. The file [`script/DoubleTokenLexscrowRegistryDeploy.s.sol`](script/DoubleTokenLexscrowRegistryDeploy.s.sol) is a convenience script for this task. To use it, set the `REGISTRY_DEPLOYER_PRIVATE_KEY` environment variable to a private key that can pay for the deployment transaction costs. Then, run the script using:

```
forge script DoubleTokenLexscrowRegistryDeploy --rpc-url <CHAIN_RPC_URL> --verify --etherscan-api-key <ETHERSCAN_API_KEY> --broadcast -vvvv
```
