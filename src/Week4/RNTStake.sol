// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { RNT } from "./RNT.sol";
import { EsRNT } from "./EsRNT.sol";

event Deposit(address, uint256);

event Withdraw(address, uint256);

event WithdrawReward(address, uint256, uint256);

contract RNTStake {
    RNT immutable rnt;
    EsRNT immutable esRNT;

    struct Staking {
        uint256 lastRewardTime;
        uint256 depositAmount;
        uint256 rewardAmount;
    }

    mapping(address => Staking) public deposits;

    constructor(address RNT_address, address esRNT_address) {
        rnt = RNT(RNT_address);
        esRNT = EsRNT(esRNT_address);
    }

    /**
     * deposit you RNT token to get esRNT
     * record deposit amount and current time
     */
    function deposit(uint256 amount) external refreshReward {
        require(rnt.balanceOf(msg.sender) >= amount);
        rnt.transferFrom(msg.sender, address(this), amount);
        deposits[msg.sender] = Staking({ lastRewardTime: block.timestamp, depositAmount: amount, rewardAmount: 0 });
        emit Deposit(msg.sender, amount);
    }

    /**
     * withdraw you RNT token
     * change the deposit amount
     */
    function withdraw(uint256 amount) external refreshReward {
        uint256 depositAmount = deposits[msg.sender].depositAmount;
        require(depositAmount >= amount, "you don't have enough money");
        rnt.transfer(msg.sender, amount);
        deposits[msg.sender].depositAmount = depositAmount - amount;
        emit Withdraw(msg.sender, amount);
    }

    modifier refreshReward() {
        uint256 currentTime = block.timestamp;
        uint256 lastTime = deposits[msg.sender].lastRewardTime;
        uint256 refrehAmount = ((currentTime - lastTime) / (3600 * 24)) * deposits[msg.sender].depositAmount;

        uint256 newAmount = deposits[msg.sender].rewardAmount + refrehAmount;
        deposits[msg.sender].rewardAmount = newAmount;
        deposits[msg.sender].lastRewardTime = currentTime;

        _;
    }

    /**
     * whithdraw reward esRNT
     */
    function withdrawReward(uint256 amount) external refreshReward {
        uint256 rewardAmount = deposits[msg.sender].rewardAmount;
        require(rewardAmount >= amount, "you don't have enough money");
        deposits[msg.sender].rewardAmount = rewardAmount - amount;
        deposits[msg.sender].lastRewardTime = block.timestamp;

        esRNT.mint(msg.sender, amount);
        emit WithdrawReward(msg.sender, block.timestamp, amount);
    }
}
