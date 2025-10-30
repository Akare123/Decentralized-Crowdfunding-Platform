// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CrowdFund
 * @dev A smart contract for creating and managing decentralized crowdfunding campaigns.
 */
contract CrowdFund {

    // Struct to represent a single funding campaign
    struct Campaign {
        address payable creator; // The person who created the campaign
        string title;            // The title of the campaign
        uint256 goal;            // The funding goal in WEI
        uint256 deadline;        // The timestamp of when the campaign ends
        uint256 totalPledged;    // The total amount of funds pledged so far
        bool claimed;            // Whether the creator has claimed the funds
    }

    // A mapping from campaign ID to the Campaign struct
    mapping(uint256 => Campaign) public campaigns;

    // A mapping to track how much each address has contributed to a campaign
    mapping(uint256 => mapping(address => uint256)) public contributions;

    // Counter for the total number of campaigns
    uint256 public campaignCounter;

    // Events
    event CampaignCreated(uint256 id, address indexed creator, string title, uint256 goal, uint256 deadline);
    event Contribution(uint256 indexed id, address indexed contributor, uint256 amount);
    event FundsClaimed(uint256 indexed id, uint256 amount);
    event RefundIssued(uint256 indexed id, address indexed contributor, uint256 amount);

    /**
     * @dev Creates a new crowdfunding campaign.
     * @param _title The title of the campaign.
     * @param _goal The funding goal in WEI.
     * @param _durationInDays The duration of the campaign in days.
     */
    function createCampaign(string memory _title, uint256 _goal) public {
        require(_goal > 0, "Goal must be greater than 0");

        uint256 campaignId = campaignCounter;
        campaigns[campaignId] = Campaign({
            creator: payable(msg.sender),
            title: _title,
            goal: _goal,
            deadline: block.timestamp + 30 days, // Fixed 30-day duration
            totalPledged: 0,
            claimed: false
        });

        emit CampaignCreated(campaignId, msg.sender, _title, _goal, campaigns[campaignId].deadline);
        campaignCounter++;
    }

    /**
     * @dev Allows users to contribute Ether to a specific campaign.
     * @param _id The ID of the campaign to contribute to.
     */
    function contribute(uint256 _id) public payable {
        Campaign storage campaign = campaigns[_id];
        
        require(block.timestamp < campaign.deadline, "Campaign has ended.");
        require(msg.value > 0, "Contribution must be greater than 0.");

        contributions[_id][msg.sender] += msg.value;
        campaign.totalPledged += msg.value;

        emit Contribution(_id, msg.sender, msg.value);
    }

    /**
     * @dev Allows the creator to claim the funds if the goal was met.
     * @param _id The ID of the campaign to claim.
     */
    function claimFunds(uint256 _id) public {
        Campaign storage campaign = campaigns[_id];

        require(msg.sender == campaign.creator, "Only the creator can claim funds.");
        require(block.timestamp >= campaign.deadline, "Campaign has not ended yet.");
        require(campaign.totalPledged >= campaign.goal, "Funding goal not reached.");
        require(!campaign.claimed, "Funds have already been claimed.");

        campaign.claimed = true;
        uint256 amount = campaign.totalPledged;

        (bool sent, ) = campaign.creator.call{value: amount}("");
        require(sent, "Failed to send Ether to creator.");

        emit FundsClaimed(_id, amount);
    }

    /**
     * @dev Allows contributors to get a refund if the campaign failed.
     * @param _id The ID of the campaign to get a refund from.
     */
    function getRefund(uint256 _id) public {
        Campaign storage campaign = campaigns[_id];
        
        require(block.timestamp >= campaign.deadline, "Campaign has not ended yet.");
        require(campaign.totalPledged < campaign.goal, "Funding goal was reached, no refunds.");

        uint256 refundAmount = contributions[_id][msg.sender];
        require(refundAmount > 0, "You did not contribute to this campaign.");

        // Reset contribution amount to prevent re-entrancy and double withdrawal
        contributions[_id][msg.sender] = 0;

        (bool sent, ) = msg.sender.call{value: refundAmount}("");
        require(sent, "Failed to send refund.");

        emit RefundIssued(_id, msg.sender, refundAmount);
    }
}
