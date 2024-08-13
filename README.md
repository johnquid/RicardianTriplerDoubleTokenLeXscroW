<p align="center">
  <img src="https://pbs.twimg.com/media/GIZRzEIXcAADT9j.png"/>
</p>

# LeXscroW Double Token Ricardian Tripler

Smart contracts for the adoption of Double Token LeXscroW Agreement as a ['ricardian triple'](https://financialcryptography.com/mt/archives/001556.html). 

## What's in this repo?

- [documents/agreement.pdf](documents/agreement.pdf) - MetaLeX Double Token LeXscroW Agreement v1 
- [registry-contracts/](registry-contracts/) - the smart contracts that parties call to parameterize and sign the agreement 

## How does it work?

- MetaLeX sets up the Ricardian tripler factory with the legal agreement form and approved factories as set forth in [Setup](https://github.com/MetaLex-Tech/RicardianTriplerDoubleTokenLeXscroW/tree/main/registry-contracts#setup)
- Parties to a Double Token LeXscroW navigate to an approved factory and become legally bound to a properly corresponding legal agreement by undertaking the steps set forth below

### Adoption/Signing

A few steps are required.

Firstly, a decision must be made regarding the agreement's terms, including:
- Confirming the parties agreement to the MetaLeX Double Token LeXscroW Agreement v1 terms 
- `governingLaw`: string input of the governing law that applies to the agreement that must be confirmed by both parties
- `disputeResolutionMethod`: string input of the dispute resolution method that applies to the agreement that must be confirmed by both parties


Once the specifics are determined, there are three final steps for adoption:

1.  A party to a Double Token LeXscroW calls `proposeDoubleTokenLexscrowAgreement()` on an `AgreementFactory` with their agreement details.
2.  The factory creates an `Agreement` contract containing the provided agreement details.
3.  The other party to the applicable Double Token LeXscroW calls `confirmAndAdoptDoubleTokenLexscrowAgreement()` with the pending agreement's details, contract address, and the address of initial proposing party to confirm adoption.
4.  The factory adds the `Agreement` contract address to the `DoubleTokenLexscrowRegistry`.
  
Each party's onchain transaction to propose and confirm (as applicable) the agreement details constitutes legally binding action, so each address calling the registry should represent the decision-making authority of the applicable party to the Double Token LeXscroW.


