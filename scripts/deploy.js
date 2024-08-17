const { ethers, run, network } = require("hardhat");

// yarn hardhat run scripts/deploy.js --network sepolia
async function main() {
    const TR3DAOFactory = await ethers.getContractFactory("TR3DAO");
    console.log("Deploying contract...");

    const nftContractAddress = "0x1234567890abcdef1234567890abcdef12345678";  // Example NFT contract address
    const validatorTokenId = 1;  // Example token ID for the validator
    const maxYesVotesPerVoter = 5;  // Example maximum number of Yes votes per voter
    const votingDuration = 3600;  // Example voting duration in seconds (e.g., 1 hour)

    // Deploy the contract with the required constructor arguments
    const TR3DAO = await TR3DAOFactory.deploy(nftContractAddress, validatorTokenId, maxYesVotesPerVoter, votingDuration);
    
    // Wait until the contract is deployed and has an address
    const deployTransaction = await TR3DAO.deploymentTransaction();
    await deployTransaction.wait();

    const address = await TR3DAO.getAddress();
    console.log(`Deployed contract to: ${address}`);

    console.log(`TARGET Deployed contract to: ${TR3DAO.target}`);

    // Automatically verify the contract if on the Sepolia network
    if (network.config.chainId === 11155111 && process.env.ETHERSCAN_API_KEY) {
        console.log("Verifying contract...");
        await verify(address, []);
    }

    // Interact with the contract if needed
    // const currentValue = await tr3dao.retrieve(); // Replace with your contract's function
    // console.log(`Current Value is ${currentValue}`);
    
    // Update the value or interact as needed
    // const transactionResponse = await tr3dao.store(7); // Replace with your contract's function
    // await transactionResponse.wait(1);
    // const updatedValue = await tr3dao.retrieve();
    // console.log(`Updated Value is ${updatedValue}`);
}

// Function to verify the contract on Etherscan
async function verify(contractAddress, args) {
    console.log("Verifying contract...");
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        });
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already Verified!");
        } else {
            console.error(e);
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
