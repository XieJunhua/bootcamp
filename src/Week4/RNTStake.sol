// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { RNT } from "./RNT.sol";
import { EsRNT } from "./EsRNT.sol";

event Deposit(address, uint256);

event Withdraw(address, uint256);

event Claim(address, uint256, uint256);

contract RNTStake {
    RNT immutable rnt;
    EsRNT immutable esRNT;

    struct Staking {
        uint256 lastRewardTime;
        uint256 depositAmount;
        uint256 rewardAmount;
    }

    struct Reward {
        uint256 lockAt;
        uint256 rewardAmount;
    }

    mapping(address => Staking) public deposits;
    mapping(address => Reward[]) public rewards;

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
        deposits[msg.sender].depositAmount = deposits[msg.sender].depositAmount + amount;

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

    /**
     * refresh reward and set lastRewardTime
     */
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
     * claim reward esRNT
     */
    function claim() external refreshReward {
        uint256 rewardAmount = deposits[msg.sender].rewardAmount;
        // require(rewardAmount >= amount, "you don't have enough money");
        deposits[msg.sender].rewardAmount = 0;
        deposits[msg.sender].lastRewardTime = block.timestamp;

        Reward[] storage rs = rewards[msg.sender];
        rs.push(Reward({ lockAt: block.timestamp, rewardAmount: rewardAmount }));
        rewards[msg.sender] = rs;

        esRNT.mint(msg.sender, rewardAmount);
        emit Claim(msg.sender, block.timestamp, rewardAmount);
    }

    /**
     * burn your esRNT and get RNT
     */
    function burn() external {
        Reward[] memory rs = rewards[msg.sender];
        uint256 currentTime = block.timestamp;
        uint256 burnAmount;
        uint256 exchangeAmount;

        for (uint256 i = 0; i < rs.length; i++) {
            uint256 lockedDays = (currentTime - rs[i].lockAt) / (3600 * 24);
            if (lockedDays >= 30) {
                exchangeAmount += rs[i].rewardAmount;
                burnAmount += rs[i].rewardAmount;
            } else {
                exchangeAmount += rs[i].rewardAmount * lockedDays / 30;
                burnAmount += rs[i].rewardAmount * (30 - lockedDays) / 30;
            }
        }
        delete rewards[msg.sender];
        _burn(burnAmount, exchangeAmount);
    }

    function _burn(uint256 burnAmount, uint256 exchangeAmount) private {
        require(esRNT.balanceOf(msg.sender) >= burnAmount, "you don't have enough esRNT");
        esRNT.burn(msg.sender, burnAmount);
        rnt.mint(msg.sender, exchangeAmount);
    }
}
