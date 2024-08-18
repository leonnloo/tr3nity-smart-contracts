# TR3NITY DAO

This repository contains the foundational voting system designed for our DeSci (Decentralized Science) platform, specifically tailored for crowdfunding initiatives for researchers. Before a research proposal can qualify for a grant and be released to the public, it must first undergo a voting process conducted by a group of validators. 

**Note**: The smart contract implementation provided here is not used in the MVP (Minimum Viable Product) <b>due to limitations in MasChain's cross-chain capabilities</b>. While this contract demonstrates how decentralized voting could be securely managed on the Ethereum network, current cross-chain interoperability challenges prevent its integration with MasChain at this stage.

## Overview

The voting system implemented in this smart contract allows validators to cast votes on research proposals during the voting phase. Validators can vote either in favor of or against a proposal. To ensure a fair and balanced voting process, each validator is limited in the number of "Yes" votes they can cast within a list of proposals under the same grant.

### Key Features

- **One Vote Per Proposal**: Each validator is allowed to cast only one vote per proposal, ensuring that the voting process is transparent and that each proposal receives equal consideration.


- **Limited Yes Votes**: Validators have a predefined maximum number of "Yes" votes they can cast across all proposals under a specific grant. This limitation ensures that validators must carefully consider which proposals they support, promoting thoughtful and strategic decision-making.

- **Validator Identity with NFTs**: Validator identity is secured and authenticated using Non-Fungible Tokens (NFTs). Each validator must hold a specific NFT that uniquely identifies them as an authorized participant in the voting process. The smart contract verifies the ownership of the NFT before allowing a validator to vote or execute a proposal, ensuring that only legitimate validators can participate.

- **DAO Governance**: The smart contract is designed to operate within a DAO framework, leveraging the principles of decentralization to enhance transparency, fairness, and accountability in the voting process.

This voting system forms a crucial part of the TR3NITY DAO, enabling the community to actively participate in the governance of research funding, and ensuring that only the most deserving proposals move forward in the grant process.

## Smart Contract Deployment

For those interested in reviewing the deployed contract, the TR3NITY DAO smart contract has been deployed on the Sepolia test network. You can refer to the contract at the following address:

**Sepolia Network Contract Address**: `0xf03Cd42F2C52F9e86C6aA0a8868a8019Bd865518`

Feel free to explore the contract on the Sepolia network and interact with it using any Ethereum-compatible wallet or tool like Etherscan or Remix. 

## Unit Testing: Simulating a Voting Situation

To ensure the integrity and functionality of the voting system, we have implemented a series of unit tests that simulate various voting scenarios. These tests are designed to validate the core features of the smart contract, including proposal creation, vote casting, and the enforcement of voting limits.

### Example Test Scenarios

1. **Proposal Creation**:

   - The contract is tested to ensure that multiple proposals can be created and stored correctly, with each proposal having a unique identifier and description.

2. **Voting by Validators**:

   - Validators cast votes on different proposals, and the contract correctly records the "Yes" and "No" votes.
   - A test ensures that validators cannot vote more than once on the same proposal.

3. **Enforcing the Maximum Yes Votes**:

   - The contract is tested to ensure that validators cannot exceed their allotted number of "Yes" votes across all proposals. If a validator attempts to cast more "Yes" votes than allowed, the transaction is reverted.

4. **Proposal Execution**:
   - Once the voting period ends, the contract allows a designated validator to execute the proposal, provided the conditions are met. The test checks that only the validator can execute the proposal and that it is properly marked as executed.

### Running the Tests

To run the unit tests and simulate these voting scenarios, follow these steps:

1. **Install Dependencies**: Ensure you have all necessary dependencies installed by running:

   ```bash
   npm install
   ```

2. **Run the Tests**: Execute the tests using the Hardhat testing framework:

   ```bash
   npx hardhat test
   ```

3. **Review Results**: The test suite will provide detailed output, showing the results of each test scenario and highlighting any issues that need to be addressed.

These unit tests are crucial for validating the functionality of the TR3NITY DAO voting system, ensuring that it behaves as expected in various real-world situations. By thoroughly testing the smart contract, we can confidently deploy a reliable and transparent voting mechanism that supports the decentralized governance of research funding.
