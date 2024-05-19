// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./IStaking.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./KK.sol";
import { Test, console2 } from "forge-std/src/Test.sol";

/**
 * @title
 * @author
 * @notice
 *
 * 编写 StakingPool 合约，实现 Stake 和 Unstake 方法，
 * 允许任何人质押ETH来赚钱 KK Token。其中 KK Token 是每一个区块产出 10 个，
 * 产出的 KK Token 需要根据质押时长和质押数量来公平分配。
 */
contract Staking is IStaking {
    uint256 constant REWARD_RATE = 10 * 1e18;
    KK immutable kk;

    using Address for address payable;

    uint128 currentRewardPerToken;
    uint128 updateAt;

    constructor(address _kk) {
        kk = KK(_kk);
    }

    struct Reward {
        uint128 stakeAmount;
        uint128 lastRewardPerToken;
        uint256 rewardAmount;
    }

    event Stake(address staker, uint256 amount);
    event UnStake(address, uint128);
    event Claim(address, uint256, uint256);

    mapping(address => Reward) stakings;

    uint256 totalDeposit;

    modifier refreshReward() {
        if (totalDeposit == 0) {
            updateAt = uint128(block.number);
            _;
            return;
        }

        currentRewardPerToken =
            currentRewardPerToken + uint128(REWARD_RATE * 1e18 * (block.number - updateAt) / totalDeposit);
        updateAt = uint128(block.number);

        stakings[msg.sender].rewardAmount = stakings[msg.sender].rewardAmount
            + stakings[msg.sender].stakeAmount * (currentRewardPerToken - stakings[msg.sender].lastRewardPerToken) / 1e18;
        stakings[msg.sender].lastRewardPerToken = currentRewardPerToken;

        _;
    }

    /**
     * @dev 质押 ETH 到合约
     */
    function stake() external payable refreshReward {
        totalDeposit += msg.value;
        // have been staked
        require(msg.value > 0, "stake amount must be greater than 0");
        stakings[msg.sender].stakeAmount += uint128(msg.value);
        emit Stake(msg.sender, msg.value);
    }

    /**
     * @dev 赎回质押的 ETH
     * @param amount 赎回数量
     */
    function unstake(uint128 amount) external refreshReward {
        totalDeposit -= amount;
        require(amount > 0, "unstake amount must be greater than 0");
        stakings[msg.sender].stakeAmount -= amount;
        payable(msg.sender).sendValue(amount);
        emit UnStake(msg.sender, amount);
    }

    /**
     * @dev 领取 KK Token 收益
     */
    function claim() external refreshReward {
        uint256 rewardAmount = stakings[msg.sender].rewardAmount;
        require(rewardAmount > 0, "no reward to claim");
        stakings[msg.sender].rewardAmount = 0;
        kk.mint(msg.sender, rewardAmount);
        emit Claim(msg.sender, block.number, rewardAmount);
    }

    /**
     * @dev 获取质押的 ETH 数量
     * @param account 质押账户
     * @return 质押的 ETH 数量
     */
    function balanceOf(address account) external view returns (uint256) {
        return stakings[account].stakeAmount;
    }

    /**
     * @dev 获取待领取的 KK Token 收益
     * @param account 质押账户
     * @return 待领取的 KK Token 收益
     */
    function earned(address account) external view returns (uint256) {
        if (totalDeposit == 0) {
            return 0;
        }
        console2.log("currentRewardPerToken: ", currentRewardPerToken);
        console2.log("rewardAmount: ", stakings[account].rewardAmount);
        console2.log("stakeAmount: ", stakings[account].stakeAmount);
        console2.log("perTokenPaid: ", stakings[account].lastRewardPerToken);
        uint256 _currentRewardsPerToken =
            currentRewardPerToken + (block.number - updateAt) * REWARD_RATE * 1e18 / totalDeposit;
        return stakings[account].rewardAmount
            + stakings[account].stakeAmount * (_currentRewardsPerToken - stakings[account].lastRewardPerToken) / 1e18;
    }
}
