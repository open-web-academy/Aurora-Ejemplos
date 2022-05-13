// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./Arbitration.sol";

contract Mediator {

    struct Dispute {
        uint64 serviceId;
        uint8 numberOfJudges;
        address[] judges;
        bool[] votes;
        DisputeStatus disputeStatus;
        uint initialTimeStamp;
        // Users
        address applicant;
        address accused;
        address winner;
        // Proves
        string applicantProves;
        string accusedProves;
    }

    struct VoteCounter {
        uint8 winningChoice; // The choice which currently has the highest amount of votes. Is 0 in case of a tie.
        uint8 winningCount;  // The number of votes for winningChoice. Or for the choices which are tied.
        mapping (uint8 => uint8) voteCount; // voteCount[choice] is the number of votes for choice.
    }

    struct Users {
        int16 reputation;
        string categories;
        string links;
    }

    enum DisputeStatus { Open, Resolving, Executable, Finished }

    mapping(address => Users) public users;
    mapping(uint128 => Dispute) disputes;
    uint128 public disputeCounter;
    
    address public owner;
    address public marketplace;
    address public token;

    uint8 public JUROR_NUMBERS = 10; 

    // *********************************************
    // *************** EVENTS **********************
    // *********************************************

    event newDispute(uint64 _id, address indexed _applicant, address _accused);

    event newDisputeStatus(uint64 _id, DisputeStatus _status);

    // *********************************************
    // ************** MODIFIERS ********************
    // *********************************************
    
    modifier onlyOwner() { require(msg.sender == owner, "Only executable by the owner"); _; }

    modifier onlyBy(address _account) {require(msg.sender == _account, "Wrong caller."); _;}

    // *********************************************
    // ************ CORE FUNCTIONS *****************
    // *********************************************

    constructor(address _token, address _marketplace) {
        owner = msg.sender;
        token = _token;
        marketplace = _marketplace;
    }

    /** @dev Create a new dispute by the employeer
     *  @param _accused address of professional accused by the employeer.
     *  @param _serviceId ID of the service for what the dispute is created.
     *  @param _proves string with proves of the employeer
     *  @return true if the dispute is created correctly
     */
    function createDispute(address _accused, uint64 _serviceId, string memory _proves) public returns(bool) {
        address[] memory empty;
        bool[] memory emptyVote;

        disputes[disputeCounter] = Dispute({
            serviceId: _serviceId,
            numberOfJudges: JUROR_NUMBERS,
            judges: empty,
            votes: emptyVote,
            disputeStatus: DisputeStatus.Open,
            initialTimeStamp: block.timestamp,
            applicant: msg.sender,
            accused: _accused,
            winner: address(0),
            applicantProves: _proves,
            accusedProves: ""
        });

        disputeCounter += 1;
        emit newDispute(_serviceId, msg.sender, _accused);

        return true;
    }

    // ************************************************
    // ************** SET FUNCTIONS *******************
    // ************************************************

    /** Set proves by the professional accused.
     *  These are in string format, representing a hash of real proves.
     *  The real proves are managed through the web app.
     *  @param _id ID of the Dispute.
     */
    function setAccusedProves(uint64 _id, string memory _proves) public returns(bool) {
        require(disputeCounter >= _id, "The indicated dispute don't exist");

        Dispute storage dispute = disputes[_id];

        // Verify the correct time
        require(dispute.disputeStatus == DisputeStatus.Open, "Time to upload proves is over");

        dispute.accusedProves = _proves;

        return true;
    }

    /** @dev Return the most important dates of a dispute.
     *  @param _new number of members of juries.
     *  @return true if the change is applied correcly.
     */
    function setNumberOfJurors(uint8 _new) public onlyOwner returns(bool) {
        JUROR_NUMBERS = _new;
        return true;
    }

    function setMediatorContract(address _marketplace) public onlyOwner returns(bool) {
        marketplace = _marketplace;
        return true;
    }

    // ************************************************
    // ************** GET FUNCTIONS *******************
    // ************************************************

    /** @dev Get the most important dates of a dispute.
     *  @return id, status and parts of the dispute.
     */
    function getDisputeById(uint64 _id) public view returns(uint64, DisputeStatus, address, address, address) {
        return (
            disputes[_id].serviceId, 
            disputes[_id].disputeStatus, 
            disputes[_id].applicant, 
            disputes[_id].accused, 
            disputes[_id].winner
        );
    }

    /** @dev Get the status of a dispute.
     *  @return status of the dispute in the call moment.
     */
    function getCurrentDisputeStatus(uint64 _id) public view returns(DisputeStatus status) {
        Dispute memory dispute = disputes[_id];
        return dispute.disputeStatus;
    }

    /** @dev Get the actual number of votes of a dispute.
     *  @return number of votes.
     */
    function getRealicedVotes(uint64 _id) public view returns(uint) {
        Dispute memory dispute = disputes[_id];
        return dispute.votes.length;
    }
}