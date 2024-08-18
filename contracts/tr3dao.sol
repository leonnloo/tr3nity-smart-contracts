// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Uncomment this line to use console.log for debugging
// import "hardhat/console.sol";

// Interface for interacting with an ERC721 (NFT) contract to check ownership
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
}

// TR3DAO contract allows decentralized voting on proposals within a DAO
contract TR3DAO {
    // Structure representing a proposal in the DAO
    struct Proposal {
        string description;  // Description of the proposal
        uint256 yesVotes;    // Number of "Yes" votes received
        uint256 noVotes;     // Number of "No" votes received
        uint256 startTime;   // Time when the proposal was created
        bool executed;       // Whether the proposal has been executed
    }

    // Address of the ERC721 contract used to verify validator identity
    IERC721 public nftContract;
    uint256 public validatorTokenId;  // Token ID used to identify the validator

    Proposal[] public proposals;  // Array storing all proposals
    mapping(uint256 => mapping(address => bool)) public hasVoted;  // Mapping to track if an address has voted on a proposal
    mapping(address => uint256) public yesVotesUsed;  // Mapping to track the number of "Yes" votes used by an address

    uint256 public maxYesVotesPerVoter;  // Maximum number of "Yes" votes allowed per voter
    uint256 public votingDuration;  // Duration of the voting period in seconds

    // Events to log actions on the blockchain
    event ProposalCreated(uint256 proposalId, string description, uint256 startTime);
    event Voted(uint256 proposalId, address voter, bool support);
    event Executed(uint256 proposalId);

    // Constructor to initialize the contract with the necessary parameters
    constructor(address _nftContract, uint256 _validatorTokenId, uint256 _maxYesVotesPerVoter, uint256 _votingDuration) {
        nftContract = IERC721(_nftContract);  // Set the ERC721 contract address
        validatorTokenId = _validatorTokenId;  // Set the token ID for the validator
        maxYesVotesPerVoter = _maxYesVotesPerVoter;  // Set the maximum number of "Yes" votes allowed per voter
        votingDuration = _votingDuration;  // Set the duration of the voting period
    }

    // Function to create a new proposal
    function createProposal(string memory _description) public {
        proposals.push(Proposal({
            description: _description,
            yesVotes: 0,
            noVotes: 0,
            startTime: block.timestamp,
            executed: false
        }));
        emit ProposalCreated(proposals.length - 1, _description, block.timestamp);  // Emit an event when a proposal is created
    }

    // Function to cast a vote on a proposal
    function vote(uint256 _proposalId, bool support) public {
        require(_proposalId < proposals.length, "Invalid proposal");  // Check that the proposal ID is valid
        require(!hasVoted[_proposalId][msg.sender], "Already voted");  // Ensure the voter has not already voted on this proposal

        Proposal storage proposal = proposals[_proposalId];  // Retrieve the proposal
        require(block.timestamp <= proposal.startTime + votingDuration, "Voting period has ended");  // Ensure voting is still open

        if (support) {
            require(yesVotesUsed[msg.sender] < maxYesVotesPerVoter, "Exceeded max yes votes");  // Check the voter hasn't exceeded their "Yes" vote limit

            proposal.yesVotes++;  // Increment the "Yes" votes count
            yesVotesUsed[msg.sender]++;  // Increment the voter's used "Yes" votes
        } else {
            proposal.noVotes++;  // Increment the "No" votes count
        }

        hasVoted[_proposalId][msg.sender] = true;  // Mark that the voter has voted on this proposal
        emit Voted(_proposalId, msg.sender, support);  // Emit an event to record the vote
    }

    // Function to execute a proposal after the voting period has ended
    function executeProposal(uint256 _proposalId) public {
        require(_proposalId < proposals.length, "Invalid proposal");  // Check that the proposal ID is valid
        require(!proposals[_proposalId].executed, "Proposal already executed");  // Ensure the proposal has not already been executed

        // Check if the caller is the validator by verifying the ownership of the specific token ID
        require(
            msg.sender == nftContract.ownerOf(validatorTokenId),
            "Not a validator"
        );

        proposals[_proposalId].executed = true;  // Mark the proposal as executed
        emit Executed(_proposalId);  // Emit an event to record the execution

        // Implement logic for what happens when a proposal passes/fails
        // e.g., if (proposals[_proposalId].yesVotes > proposals[_proposalId].noVotes) { ... }
    }

    // Function to retrieve the top N proposals based on the number of "Yes" votes
    function getTopProposals(uint256 topN) public view returns (uint256[] memory) {
        require(topN > 0 && topN <= proposals.length, "Invalid number of top proposals");  // Validate the number of top proposals requested

        uint256[] memory topProposalIds = new uint256[](topN);  // Array to store the top proposal IDs
        uint256[] memory sortedIndexes = new uint256[](proposals.length);  // Array to store the sorted indexes of proposals
        uint256[] memory yesVotesArray = new uint256[](proposals.length);  // Array to store the yes votes for each proposal

        // Create an array of proposal indexes and their respective yes votes
        for (uint256 i = 0; i < proposals.length; i++) {
            sortedIndexes[i] = i;
            yesVotesArray[i] = proposals[i].yesVotes;
        }

        // Sort proposals based on yes votes (descending order)
        for (uint256 i = 0; i < proposals.length; i++) {
            for (uint256 j = i + 1; j < proposals.length; j++) {
                if (yesVotesArray[i] < yesVotesArray[j]) {
                    // Swap yes votes
                    uint256 tempVotes = yesVotesArray[i];
                    yesVotesArray[i] = yesVotesArray[j];
                    yesVotesArray[j] = tempVotes;

                    // Swap indexes
                    uint256 tempIndex = sortedIndexes[i];
                    sortedIndexes[i] = sortedIndexes[j];
                    sortedIndexes[j] = tempIndex;
                }
            }
        }

        // Select the top N proposals
        for (uint256 i = 0; i < topN; i++) {
            topProposalIds[i] = sortedIndexes[i];
        }

        return topProposalIds;  // Return the array of top proposal IDs
    }

    // Function to get details of a specific proposal
    function getProposal(uint256 _proposalId) public view returns (
        string memory description,
        uint256 yesVotes,
        uint256 noVotes,
        uint256 startTime,
        bool executed
    ) {
        require(_proposalId < proposals.length, "Invalid proposal");  // Check that the proposal ID is valid

        Proposal storage proposal = proposals[_proposalId];  // Retrieve the proposal
        return (proposal.description, proposal.yesVotes, proposal.noVotes, proposal.startTime, proposal.executed);  // Return proposal details
    }

    // Function to get the total number of proposals
    function getProposalsCount() public view returns (uint256) {
        return proposals.length;  // Return the number of proposals
    }
}
