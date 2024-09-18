
pragma solidity ^0.8.18;

// TODO library

enum AffadavitType {
    ENDORSEMENT, // We look forward to mostly seeing endorsements
    COUNTERCLAIM, // (not encouraging tortious litigiousness)...
}

struct Affadavit {
    // description of the triable issue 
    //  (if type objection what is the alleged civil wrong, 
    //  if type endorsement, was the quality of service up to standard) 
    string description;
}

/// @notice the details of an account in an agreement

// If the party that initiated an objection did so out of malice 
// and without a legitimate legal reason, and ended up getting overruled, 
// the party can be liable for malicious prosecution. Abuse of process 
// can apply to any person using a legal process against another in an 
// improper manner, or to accomplish a purpose for which the process wasn't designed.  
// There is a difference between competitive practices and predatory actions undertaken
//  with the intention of gaining a greater share of the market. 
// The difference between the torts of abuse of process and malicious prosecution is the level of proof.

struct Dispute {
    // indeces of relevant conditions, for sufficient stake in a matter to justify seeking relief
    uint[] conditions;
    // must be one of the parties
    address defendant;
    // must the other party
    address affiant;
    // false until true
    bool unanimous;
    
    // Evidence[] ;

    string claim;
    // e.g. disparagement of property: occurs when economically injurious falsehoods are made 
    // about someone’s product or property rather than about someone’s reputation 
    // (as in the tort of defamation, though the two are closely linked)...
    // Trade libel (or slander of quality) is one such type of disparagement. 
    // The other, slander of title, relates to conversion...
    // Conversion: is any act that deprives an owner of personal property, 
    // or the use of that property without the owner’s permission and without 
    // just cause can constitute conversion. Someone who buys stolen goods, 
    // for instance, may be sued for conversion even they were unaware of it.
}

enum Motion { // to...
    DISMISS, // (requires submitMotion caller to be dispute creator)
    COUNTERCLAIM,
    AFFIRMATIVE_DEFENSE, 
    MAKE_MORE_DEFINITE_OR_CERTAIN
}

enum Objection {
    HEARSAY,
    LEADING,
    RELEVANCY
}


// voirDire(disputeId, jurorId) 
// for expert witnesses or investigators (jury), 
// submit questioning results for a jurors, which determines
// the relevance and merit of their backgrounds, attitudes, 
// and similar attributes in determining whether they may be 
// biased, or connected in any way to a witness or party to the action.

// construe(evidence id) can be met with an Objection 
// validate the dispute showing (through evidence and argument) interpretation 
// or explaination of something according to judicial standards. May include a 
// discovery request, containing interrogatories (questions to be answered... 
// encouraging dissenting opinions, presenting a view that may disagreeing with the majority)
// Proximate cause asks whether the sustained effects were foreseeable or were too remotely 
// connected to the incident. Superseding cause is an unforeseeable intervening event that 
// breaks the causal connection between an act deemed wrongful and the effect in question.

// deposition(evidence id)
// Produces sworn testimony by plaintiff, defendant, or any witness. 
// needs to be construed (new evidence linking to previous evidence).
