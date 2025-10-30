# Decentralized Crowdfunding Platform

A Solidity-based smart contract that functions as a decentralized crowdfunding platform, similar to Kickstarter or GoFundMe.

## Description

This project enables users to create fundraising campaigns with a specific goal and a 30-day deadline. Other users can contribute Ether to these campaigns.

-   If a campaign successfully reaches its funding goal by the deadline, the creator can withdraw the total amount raised.
-   If the campaign fails to meet its goal, contributors can withdraw their contributions for a full refund.

## Features

-   **Campaign Creation:** Anyone can create a new campaign with a title and funding goal.
-   **Contributions:** Anyone can contribute Ether to an active campaign.
-   **Secure Payouts:** Funds are locked in the contract until the campaign concludes.
-   **Conditional Logic:**
    -   Successful campaigns allow the creator to claim the funds.
    -   Failed campaigns allow contributors to claim a refund.
-   **Time-Based Rules:** Campaigns have a fixed 30-day deadline enforced by `block.timestamp`.

## Concepts Demonstrated

-   `struct`: To organize and manage data for each campaign.
-   `payable`: To allow functions and addresses to receive Ether.
-   `block.timestamp`: For handling time-dependent logic.
--   `call{value: ...}`: The recommended, secure way to send Ether from a contract.
-   State Management: Tracking the lifecycle of a campaign (Funding, Succeeded, Failed).
-   Event Logging: Emitting events for key actions like creation, contribution, and withdrawal.
-   Basic Re-entrancy Protection: Zeroing out a user's contribution before sending a refund.

## Getting Started

### Prerequisites

-   An Ethereum development environment like [Remix IDE](https://remix.ethereum.org/).

### Usage with Remix IDE

1.  Open [Remix IDE](https://remix.ethereum.org/).
2.  Create a new file `CrowdFund.sol` and paste in the contract code.
3.  Compile the contract.
4.  Deploy the contract.
5.  **Create a Campaign:**
    -   Use the `createCampaign` function.
    -   Set a `_title` (e.g., "My Awesome Project").
    -   Set a `_goal` in Wei (e.g., `1000000000000000000` for 1 Ether).
    -   Click "transact". This will create campaign with ID `0`.
6.  **Contribute to the Campaign:**
    -   Switch to a different account in Remix.
    -   In the "Value" field at the top of the "Deploy & Run" tab, enter an amount of Ether (e.g., 0.5) and select "Ether" from the dropdown.
    -   Call the `contribute` function with the campaign `_id` (e.g., `0`).
    -   Click "transact".
7.  **Test the Outcomes:**
    -   **Success Case:** Contribute enough Ether from different accounts to meet the goal. Once the deadline passes (you'll need to wait or use a testnet/local chain where you can advance time), the creator can call `claimFunds`.
    -   **Failure Case:** Don't meet the goal. Once the deadline passes, any contributor can call `getRefund` to retrieve their funds.

## License

This project is licensed under the MIT License.
