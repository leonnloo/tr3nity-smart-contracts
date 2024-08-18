const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TR3DAO", function () {
  let TR3DAO, tr3dao;
  let owner, user1, user2;
  let nftContractAddress = "0x0000000000000000000000000000000000000000"; // Placeholder address
  let validatorTokenId = 1;
  let maxYesVotesPerVoter = 3;
  let votingDuration = 3600; // 1 hour in seconds

  beforeEach(async function () {
    // Get the signers
    [owner, user1, user2] = await ethers.getSigners();

    // Deploy the TR3DAO contract
    const TR3DAOFactory = await ethers.getContractFactory("TR3DAO");
    tr3dao = await TR3DAOFactory.deploy(
      nftContractAddress,
      validatorTokenId,
      maxYesVotesPerVoter,
      votingDuration
    );
    const deployTransaction = await tr3dao.deploymentTransaction();
    await deployTransaction.wait();
  });

  it("should create proposals", async function () {
    await tr3dao.createProposal("Proposal 1: Improve community engagement");
    await tr3dao.createProposal("Proposal 2: Increase developer rewards");
    await tr3dao.createProposal("Proposal 3: Add new features to the DAO");

    expect(await tr3dao.getProposalsCount()).to.equal(3);

    const proposal1 = await tr3dao.getProposal(0);
    expect(proposal1.description).to.equal(
      "Proposal 1: Improve community engagement"
    );
  });

  it("should allow users to vote on proposals", async function () {
    await tr3dao.createProposal("Proposal 1: Improve community engagement");

    // User1 votes "Yes"
    await tr3dao.connect(user1).vote(0, true);

    // User2 votes "No"
    await tr3dao.connect(user2).vote(0, false);

    const proposal = await tr3dao.getProposal(0);
    expect(proposal.yesVotes).to.equal(1);
    expect(proposal.noVotes).to.equal(1);
  });

  it("should prevent users from voting more than allowed times on same proposal", async function () {
    await tr3dao.createProposal("Proposal 1: Improve community engagement");
    await tr3dao.createProposal("Proposal 2: Increase developer rewards");

    // User1 votes "Yes" on Proposal 1
    await tr3dao.connect(user1).vote(0, true);

    // User1 tries to vote again on Proposal 1 - should fail
    await expect(tr3dao.connect(user1).vote(0, true)).to.be.revertedWith(
      "Already voted"
    );

    const proposal1 = await tr3dao.getProposal(0);

    expect(proposal1.yesVotes).to.equal(1);
  });
  it("should prevent users from exceeding the maximum number of yes votes", async function () {
    await tr3dao.createProposal("Proposal 1: Improve community engagement");
    await tr3dao.createProposal("Proposal 2: Increase developer rewards");
    await tr3dao.createProposal("Proposal 3: Heart Cancer");
    await tr3dao.createProposal("Proposal 4: Cancer");

    // User1 votes "Yes" on Proposal 1
    await tr3dao.connect(user1).vote(0, true);

    // User1 votes "Yes" on Proposal 2
    await tr3dao.connect(user1).vote(1, true);
    await tr3dao.connect(user1).vote(2, true);

    // User1 tries to vote "Yes" on a new proposal but exceeds the max yes votes - should fail
    await expect(tr3dao.connect(user1).vote(3, true)).to.be.revertedWith(
      "Exceeded max yes votes"
    );

    const proposal1 = await tr3dao.getProposal(0);
    const proposal2 = await tr3dao.getProposal(1);

    expect(proposal1.yesVotes).to.equal(1);
    expect(proposal2.yesVotes).to.equal(1);
  });

  it("should return the top proposals by yes votes", async function () {
    await tr3dao.createProposal("Proposal 1: Improve community engagement");
    await tr3dao.createProposal("Proposal 2: Increase developer rewards");
    await tr3dao.createProposal("Proposal 3: Add new features to the DAO");

    // Voting by users
    await tr3dao.connect(user1).vote(0, true); // Proposal 1 gets 1 yes vote
    await tr3dao.connect(user2).vote(2, true); // Proposal 3 gets 2 yes votes
    await tr3dao.connect(user1).vote(2, true);

    const topProposals = await tr3dao.getTopProposals(2);
    expect(topProposals.length).to.equal(2);
    expect(topProposals[0].toString()).to.equal("2"); // Proposal 3 has the most yes votes
  });
});
