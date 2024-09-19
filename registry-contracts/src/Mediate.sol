
pragma solidity ^0.8.18;

// TODO library

// import "./Dependencies/VRFConsumerBaseV2.sol";
// import "./Dependencies/VRFCoordinatorV2Interface.sol";



contract LEXgrow is VRFConsumerBaseV2 {
    struct Affadavit { // orderbook order
        // description of the triable issue 
        //  (if type objection what is the alleged civil wrong, 
        //  if type endorsement, was the quality of service up to standard) 
        string description;
    }   
        enum AffadavitType {
        ENDORSEMENT, // We look forward to mostly seeing endorsements
        COUNTERCLAIM, // (not encouraging tortious litigiousness)...
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

    event RequestedRandomness(uint requestId);
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINK; bytes32 keyHash;

    uint public requestId; 
    uint randomness; // 🎲
    address public winner;
    uint32 callbackGasLimit;
    uint16 requestConfirmations;
    uint64 public subscriptionId;

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

    uint256 constant appealWindow = 3 minutes;
    uint256 internal arbitrationFee = 1e15;

    error NotOwner();
    error InsufficientPayment(uint256 _available, uint256 _required);
    error InvalidRuling(uint256 _ruling, uint256 _numberOfChoices);
    error InvalidStatus(DisputeStatus _current, DisputeStatus _expected);
    error BeforeAppealPeriodEnd(uint256 _currentTime, uint256 _appealPeriodEnd);
    error AfterAppealPeriodEnd(uint256 _currentTime, uint256 _appealPeriodEnd);

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
            
            uint256 choices;
            uint256 ruling;
            DisputeStatus status;
            uint256 appealPeriodStart;
            uint256 appealPeriodEnd;
            uint256 appealCount;
    }

    Dispute[] public disputes;
    // select jury 
    // // requestId = COORDINATOR.requestRandomWords(
            //     keyHash, subscriptionId,
            //     requestConfirmations,
            //     callbackGasLimit, 1
            // );  emit RequestedRandomness(requestId);

    // function fulfillRandomWords(uint _requestId, 
    //     uint[] memory randomWords) internal override { 
    //     randomness = randomWords[0]; uint when = current; 
    //     uint shirt = ICollection(SHIRT).latestTokenId(); 
    //     address racked = ICollection(SHIRT).ownerOf(shirt);
    //     require(randomness > 0 && _requestId == requestId 
    //         && address(this) == racked, "MA::randomWords"); 
    //     // TODO who voted in this batch gets to be part of 
    //     // address[] memory from votes[_currentBatch()]
    //     uint index = randomness % votes.length;
    //     ICollection(SHIRT).transferFrom( 
    //         address(this), votes[index], shirt
    //     ); 
    // }
    // voirDire(disputeId, jurorId) 
    // for expert witnesses or investigators (jury), 
    // submit questioning results for a jurors, which determines
    // the relevance and merit of their backgrounds, attitudes, 
    // and similar attributes in determining whether they may be 
    // biased, or connected in any way to a witness or party to the action.

    // bytes32 _hash: the gas lane key hash value,
    // which is the maximum gas price willing to
    // pay for a request in wei. functions as ID 
    // of the offchain VRF job (for onReceived)s.
    constructor(/* address _vrf, address _link, bytes32 _hash, 
                uint32 _limit, uint16 _confirm, */ address _mo) 
                /* VRFConsumerBaseV2(_vrf) */ ) {
        
         // LINK = LinkTokenInterface(_link); 
        // requestConfirmations = _confirm;
        
        // callbackGasLimit = _limit; keyHash = _hash;
         // COORDINATOR = VRFCoordinatorV2Interface(_vrf);    
        // subscriptionId = COORDINATOR.createSubscription(); 
        // // the secret of sound money is after you lien, you
        // // are responsible for every sound you make ever...
        // // call it sound money due to the sine wave discounts
        // COORDINATOR.addConsumer(subscriptionId, address(this));
    }
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

    function arbitrationCost(bytes memory _extraData) public view override returns (uint256) {
        return arbitrationFee;
    }

    function appealCost(uint256 _disputeID, bytes memory _extraData) public view override returns (uint256) {
        return arbitrationFee * (2**(disputes[_disputeID].appealCount));
    }

    function setArbitrationCost(uint256 _newCost) public {
        arbitrationFee = _newCost;
    }

    function createDispute(uint256 _choices, bytes memory _extraData)
        public
        payable
        override
        returns (uint256 disputeID)
    {
        uint256 requiredAmount = arbitrationCost(_extraData);
        if (msg.value > requiredAmount) {
            revert InsufficientPayment(msg.value, requiredAmount);
        }

        disputes.push(
            Dispute({
                arbitrated: IArbitrable(msg.sender),
                choices: _choices,
                ruling: 0,
                status: DisputeStatus.Waiting,
                appealPeriodStart: 0,
                appealPeriodEnd: 0,
                appealCount: 0
            })
        );

        disputeID = disputes.length - 1;
        emit DisputeCreation(disputeID, IArbitrable(msg.sender));
    }

    function disputeStatus(uint256 _disputeID) public view override returns (DisputeStatus status) {
        Dispute storage dispute = disputes[_disputeID];
        if (disputes[_disputeID].status == DisputeStatus.Appealable && block.timestamp >= dispute.appealPeriodEnd)
            return DisputeStatus.Solved;
        else return disputes[_disputeID].status;
    }

    function currentRuling(uint256 _disputeID) public view override returns (uint256 ruling) {
        ruling = disputes[_disputeID].ruling;
    }

    function giveRuling(uint256 _disputeID, uint256 _ruling) public {
        // TODO incorporate the median weight 

        Dispute storage dispute = disputes[_disputeID];

        if (_ruling > dispute.choices) {
            revert InvalidRuling(_ruling, dispute.choices);
        }
        if (dispute.status != DisputeStatus.Waiting) {
            revert InvalidStatus(dispute.status, DisputeStatus.Waiting);
        }

        dispute.ruling = _ruling;
        dispute.status = DisputeStatus.Appealable;
        dispute.appealPeriodStart = block.timestamp;
        dispute.appealPeriodEnd = dispute.appealPeriodStart + appealWindow;

        emit AppealPossible(_disputeID, dispute.arbitrated);
    }

    function executeRuling(uint256 _disputeID) public {
        Dispute storage dispute = disputes[_disputeID];
        if (dispute.status != DisputeStatus.Appealable) {
            revert InvalidStatus(dispute.status, DisputeStatus.Appealable);
        }

        if (block.timestamp <= dispute.appealPeriodEnd) {
            revert BeforeAppealPeriodEnd(block.timestamp, dispute.appealPeriodEnd);
        }

        dispute.status = DisputeStatus.Solved;
        dispute.arbitrated.rule(_disputeID, dispute.ruling);
    }

    function appeal(uint256 _disputeID, bytes memory _extraData) public payable override {
        Dispute storage dispute = disputes[_disputeID];
        dispute.appealCount++;

        uint256 requiredAmount = appealCost(_disputeID, _extraData);
        if (msg.value < requiredAmount) {
            revert InsufficientPayment(msg.value, requiredAmount);
        }

        if (dispute.status != DisputeStatus.Appealable) {
            revert InvalidStatus(dispute.status, DisputeStatus.Appealable);
        }

        if (block.timestamp > dispute.appealPeriodEnd) {
            revert AfterAppealPeriodEnd(block.timestamp, dispute.appealPeriodEnd);
        }

        dispute.status = DisputeStatus.Waiting;

        emit AppealDecision(_disputeID, dispute.arbitrated);
    }

    function appealPeriod(uint256 _disputeID) public view override returns (uint256 start, uint256 end) {
        Dispute storage dispute = disputes[_disputeID];

        return (dispute.appealPeriodStart, dispute.appealPeriodEnd);
    }
}
