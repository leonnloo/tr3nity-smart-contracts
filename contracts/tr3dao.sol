// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

// Uncomment this line to use console.log
// import "hardhat/console.sol";


interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract TR3DAO {
    struct Proposal {
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 startTime;
        bool executed;
    }

    IERC721 public nftContract;
    uint256 public validatorTokenId;

    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(address => uint256) public yesVotesUsed;

    uint256 public maxYesVotesPerVoter;
    uint256 public votingDuration; // Voting period in seconds

    event ProposalCreated(uint256 proposalId, string description, uint256 startTime);
    event Voted(uint256 proposalId, address voter, bool support);
    event Executed(uint256 proposalId);

    constructor(address _nftContract, uint256 _validatorTokenId, uint256 _maxYesVotesPerVoter, uint256 _votingDuration) {
        nftContract = IERC721(_nftContract);
        validatorTokenId = _validatorTokenId;
        maxYesVotesPerVoter = _maxYesVotesPerVoter;
        votingDuration = _votingDuration;
    }

    function createProposal(string memory _description) public {
        proposals.push(Proposal({
            description: _description,
            yesVotes: 0,
            noVotes: 0,
            startTime: block.timestamp,
            executed: false
        }));
        emit ProposalCreated(proposals.length - 1, _description, block.timestamp);
    }

    function vote(uint256 _proposalId, bool support) public {
        require(_proposalId < proposals.length, "Invalid proposal");
        require(!hasVoted[_proposalId][msg.sender], "Already voted");

        Proposal storage proposal = proposals[_proposalId];
        require(block.timestamp <= proposal.startTime + votingDuration, "Voting period has ended");

        if (support) {
            require(yesVotesUsed[msg.sender] < maxYesVotesPerVoter, "Exceeded max yes votes");

            proposal.yesVotes++;
            yesVotesUsed[msg.sender]++;
        } else {
            proposal.noVotes++;
        }

        hasVoted[_proposalId][msg.sender] = true;
        emit Voted(_proposalId, msg.sender, support);
    }

    function executeProposal(uint256 _proposalId) public {
        require(_proposalId < proposals.length, "Invalid proposal");
        require(!proposals[_proposalId].executed, "Proposal already executed");

        // Check if the caller is a validator
        require(
            msg.sender == nftContract.ownerOf(validatorTokenId),
            "Not a validator"
        );

        proposals[_proposalId].executed = true;
        emit Executed(_proposalId);

        // Implement logic for what happens when a proposal passes/fails
        // e.g., if (proposals[_proposalId].yesVotes > proposals[_proposalId].noVotes) { ... }
    }

    function getTopProposals(uint256 topN) public view returns (uint256[] memory) {
        require(topN > 0 && topN <= proposals.length, "Invalid number of top proposals");

        uint256[] memory topProposalIds = new uint256[](topN);
        uint256[] memory sortedIndexes = new uint256[](proposals.length);
        uint256[] memory yesVotesArray = new uint256[](proposals.length);

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

        return topProposalIds;
    }

    function getProposal(uint256 _proposalId) public view returns (
        string memory description,
        uint256 yesVotes,
        uint256 noVotes,
        uint256 startTime,
        bool executed
    ) {
        require(_proposalId < proposals.length, "Invalid proposal");

        Proposal storage proposal = proposals[_proposalId];
        return (proposal.description, proposal.yesVotes, proposal.noVotes, proposal.startTime, proposal.executed);
    }

    function getProposalsCount() public view returns (uint256) {
        return proposals.length;
    }
}
