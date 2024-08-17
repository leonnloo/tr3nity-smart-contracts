const { ethers } = require("hardhat");

async function main() {
    // Replace with the address of your deployed contract
    const tr3daoAddress = "0xf03Cd42F2C52F9e86C6aA0a8868a8019Bd865518";

    // Get a reference to the deployed contract
    const TR3DAO = await ethers.getContractAt("TR3DAO", tr3daoAddress);

    console.log("Interacting with TR3DAO contract...");

    // Example: Creating a proposal
    console.log("Creating a proposal...");
    const createProposalTx = await TR3DAO.createProposal("Proposal 1: Improve community engagement");
    await createProposalTx.wait();
    console.log("Proposal created!");

    // Example: Getting proposal details
    const proposalId = 0; // Assuming this is the first proposal created
    const proposalDetails = await TR3DAO.getProposal(proposalId);
    console.log(`Proposal ${proposalId} details:`);
    console.log(`Description: ${proposalDetails[0]}`);
    console.log(`Yes Votes: ${proposalDetails[1]}`);
    console.log(`No Votes: ${proposalDetails[2]}`);
    console.log(`Start Time: ${new Date(proposalDetails[3] * 1000).toLocaleString()}`);
    console.log(`Executed: ${proposalDetails[4]}`);

    // Example: Voting on the proposal
    console.log("Voting on the proposal...");
    const voteTx = await TR3DAO.vote(proposalId, true); // true for "Yes", false for "No"
    await voteTx.wait();
    console.log("Voted successfully!");

    // Example: Executing the proposal (assuming the voting period has ended)
    console.log("Attempting to execute the proposal...");
    try {
        const executeProposalTx = await TR3DAO.executeProposal(proposalId);
        await executeProposalTx.wait();
        console.log("Proposal executed successfully!");
    } catch (error) {
        console.log("Failed to execute proposal:", error.message);
    }

    // Example: Fetching the top proposals
    console.log("Fetching top proposals...");
    const topN = 1; // Number of top proposals you want to fetch
    const topProposals = await TR3DAO.getTopProposals(topN);
    console.log(`Top ${topN} proposal IDs:`, topProposals.map(id => id.toString()));

    // Fetch and display details for the top proposal(s)
    for (let i = 0; i < topProposals.length; i++) {
        const topProposalDetails = await TR3DAO.getProposal(topProposals[i]);
        console.log(`Top Proposal ${i + 1} details:`);
        console.log(`Description: ${topProposalDetails[0]}`);
        console.log(`Yes Votes: ${topProposalDetails[1]}`);
        console.log(`No Votes: ${topProposalDetails[2]}`);
        console.log(`Start Time: ${new Date(topProposalDetails[3] * 1000).toLocaleString()}`);
        console.log(`Executed: ${topProposalDetails[4]}`);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Error interacting with the contract:", error);
        process.exit(1);
    });
