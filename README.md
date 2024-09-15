<p align="center">
  <img src="https://pbs.twimg.com/media/GIZRzEIXcAADT9j.png"/>
</p>

# Double Token LeXscroW Ricardian Tripler

Smart contracts for the adoption of Double Token LeXscroW Agreement as a ['ricardian triple'](https://financialcryptography.com/mt/archives/001556.html). 

## What's in this repo?

- [documents/agreement.pdf](documents/agreement.pdf) - MetaLeX Double Token LeXscroW Agreement v1 
- [registry-contracts/](registry-contracts/) - the smart contracts that parties call to parameterize and sign the agreement 

## How does it work?

- MetaLeX sets up the Ricardian tripler factory with the legal agreement form and approved factories as set forth in [Setup](https://github.com/MetaLex-Tech/RicardianTriplerDoubleTokenLeXscroW/tree/main/registry-contracts#setup)
- Parties to a Double Token LeXscroW navigate to an approved factory and become legally bound to a properly corresponding legal agreement by undertaking the steps set forth below

## Adoption/Signing

A few steps are required.

Firstly, the parties must come to an agreement regarding the proposed agreement's terms, including:
- Confirming suitability and acceptance of the MetaLeX Double Token LeXscroW Agreement v1 terms 
- `governingLaw`: string input of the governing law that applies to the agreement 
- `disputeResolutionMethod`: string input of the dispute resolution method that applies to the agreement


Once the specifics are determined, there are two final steps for adoption:

1.  A party calls either:
* (a) `deployLexscrowAndProposeDoubleTokenLexscrowAgreement()` to deploy a Double Token LeXscroW contract with the same parameters included in the passed `AgreementDetails`, or
* (b) `proposeDoubleTokenLexscrowAgreement()` including the parameters to an already-deployed Double Token LeXscroW in the passed `AgreementDetails`, in each case on an `AgreementFactory`.

  
The `AgreementFactory` creates a `RicardianTriplerDoubleTokenLexscrow` agreement contract containing the provided proposed agreement details. In either case, the details include all of the parameters used to construct the Double Token LeXscroW contract, as well as each party's name and contact details, the legal agreement's URI, and elected governing law and dispute resolution method.

2.  To confirm the details and formally adopt the `RicardianTriplerDoubleTokenLexscrow`, the other party to the applicable Double Token LeXscroW calls `confirmAndAdoptDoubleTokenLexscrowAgreement()` with `AgreementDetails` matching the pending agreement's details, contract address, and the address of initial proposing party. The factory adds the `RicardianTriplerDoubleTokenLexscrow` contract address to the `DoubleTokenLexscrowRegistry`, updating both the `agreements`and `signedAgreement` mappings.

A user may check if a `RicardianTriplerDoubleTokenLexscrow` agreement was mutually signed (and thus recorded in the registry) by passing its address to the `signedAgreement` mapping in the `DoubleTokenLexscrowRegistry`; if it returns `true`, the agreement's details are then easily accessed by calling `getDetails()` directly in the `RicardianTriplerDoubleTokenLexscrow` contract address.
  
Each party's onchain transaction to propose and confirm (as applicable) the agreement details constitutes legally binding action, so each transacting address should represent the decision-making authority of the applicable party to the Double Token LeXscroW.

## Arbitration

Implied warranties can arise (or be excluded or modified) as a  
result of *course of [dealing](https://metalex.substack.com/i/142402118/phase-deal-technology)*  (prior conduct between the parties),  
or usage of trade. May include inducing others to try something  
on the basis of one’s positive review (attractive nuisance doctrine).  

In the absence of unanimous evidence to the contrary,  when  
both signing parties to a sales / lease contract (or service-level  
agreement) have knowledge of a [well-recognized](https://x.com/lex_node/status/1831514207227101477) trade custom,  
arbitration will infer that both parties intended for said trade  
custom to apply to their contract, according to a hypothetical  
reasonable person standard. It is society’s judgement of how  
an ordinarily prudent person would act (conscientiously, etc.)

For professionals, a standard level of special knowledge and  
training or expertise is considered. Informal agreements are   
unilateral based on their substance rather  than their form.  
Most agreements are informal, containing a mix of express  
terms and implied terms: contests, lotteries, and other such   
competitions are common examples of unilateral contracts.

Gross negligence in relation to reasonable duty of care can  
be defined as an intentional failure to perform. This is rare.  
The standard of comparative negligence applies to most  
cases. Both the plaintiff’s and the defendant’s negligence  
are computed, and the liability for damages is distributed  
accordingly. We apply a 50% rule, preventing the plaintiff  
from recovering any damages if they were >50% at fault.

