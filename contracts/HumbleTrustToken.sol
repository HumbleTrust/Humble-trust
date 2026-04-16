// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HumbleTrustToken is ERC20, Ownable {
    mapping(address => uint256) public lockTimestamp;
    mapping(address => uint256) public trustScores;

    uint256 public constant MIN_LOCK_PERIOD = 90 days;
    uint256 public lockedSupply;
    address payable public feeRecipient = payable(0xFYRtG8JMun6vqucUaXGcSZrWib6gNVEW4dd2LEP92mGM);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        require(bytes(name).length <= 16, "Name must be 16 characters or less.");
        require(bytes(symbol).length <= 5, "Symbol must be 5 characters or less.");
    }

    function createToken(uint256 amount, uint256 lockDuration, uint256 trustScore) external payable {
        require(msg.value == 0.4 ether, "Fee of 0.4 SOL required.");
        require(lockDuration >= MIN_LOCK_PERIOD, "Minimum lock period is 90 days.");
        require(trustScore >= 30 && trustScore <= 80, "Trust score must be between 30 and 80.");

        _mint(msg.sender, amount);
        lockTimestamp[msg.sender] = block.timestamp + lockDuration;
        trustScores[msg.sender] = trustScore;
        lockedSupply += amount;

        feeRecipient.transfer(msg.value);
    }

    function sell(uint256 amount) external {
        require(block.timestamp > lockTimestamp[msg.sender], "Tokens are locked.");
        require(amount <= totalSupply() * 5 / 100, "Cannot sell more than 5% of total supply per transaction.");

        _transfer(msg.sender, address(this), amount);
        // Additional logic for selling tokens (e.g., liquidity pool integration) would go here.
    }

    function getTrustScore(address user) external view returns (uint256) {
        return trustScores[user];
    }

    function withdraw() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
}