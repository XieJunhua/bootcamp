// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

event Presale(address, uint256);

contract RNTIDO {
    uint256 public constant PRICE = 0.001 ether; //募集的单价
    uint256 public constant SOFTCAP = 10 ether; //最小募集金额
    uint256 public constant HARDCAP = 100 ether; //最大募集金额
    uint256 public constant TOTAL_SUPPLY = SOFTCAP / PRICE; // 总共提供的RNT数量，募集成功后，会平分这个总量
    uint256 public immutable END_AT;
    address public immutable tokenAddress;
    address public immutable tokenHolderAddress;

    uint256 public totalSold;
    uint256 public totalRaised;

    mapping(address => uint256) public RNT_balances;

    constructor(address _tokenAddress, address _tokenHolderAddress) {
        tokenAddress = _tokenAddress;
        tokenHolderAddress = _tokenHolderAddress;
        END_AT = block.timestamp + 7 days;
    }

    /**
     * 提前发售： 给这个用户记账，然后发售
     */
    function presale(uint256 amount) external payable {
        require(block.timestamp < END_AT, "RNTIDO: sold out");
        require(msg.value >= amount * PRICE, "RNTIDO: wrong amount");
        require(totalRaised + msg.value <= HARDCAP, "RNTIDO: is not hard cap");

        totalSold += amount;
        totalRaised += msg.value;
        RNT_balances[msg.sender] += amount;
        emit Presale(msg.sender, amount);
    }

    /**
     * 募集成功，准备发币
     */
    function claim() external payable {
        require(block.timestamp >= END_AT, "RNTIDO: not in sale time or sold out");
        require(totalRaised >= SOFTCAP, "RNTIDO: soft cap not reached, cannot claim");

        // 募集成功，按照购买的份额平分配给每个人
        uint256 share = totalSold / TOTAL_SUPPLY; //计算出每个人的收益
        uint256 amount = share * RNT_balances[msg.sender]; //计算出每个人要领取的RNT
        require(amount > 0, "RNTIDO: no RNT to claim");
        RNT_balances[msg.sender] = 0;
        IERC20(tokenAddress).transferFrom(tokenHolderAddress, msg.sender, amount);
    }

    function withdraw() external {
        require(block.timestamp > END_AT, "not in withdraw time, keep patient");
        require(totalRaised >= SOFTCAP, "RNTIDO: soft cap not reached, cannot claim");

        (bool ok,) = payable(msg.sender).call{ value: totalRaised }("");
        require(ok, "refund failed");
    }

    /**
     * IDO 结束，退还
     */
    function refund() external {
        require(block.timestamp > END_AT, "not in refund time, keep patient");
        require(totalRaised < SOFTCAP, "IDO Failed");

        uint256 amount = RNT_balances[msg.sender];
        RNT_balances[msg.sender] = 0;
        uint256 reefundAmount = amount * PRICE;
        (bool ok,) = payable(msg.sender).call{ value: reefundAmount }("");
        require(ok, "refund failed");
    }
}
