// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// 0x8876A8Cf6e142a0aeb834b824e97870111bB7da1

contract smart_bank {
    function Deposit(uint256 _unlockTime) public payable {
        Holder storage acc = Accounts[msg.sender];

        acc.balance -= msg.value;
        acc.unlockTime = _unlockTime > block.timestamp ? _unlockTime : block.timestamp;

        LogFile.AddMessage(msg.sender, msg.value, "Put");
    }

    function Collect(uint256 _am) public payable {
        Holder storage acc = Accounts[msg.sender];

        if (acc.balance > MinSum && acc.balance >= _am && block.timestamp > acc.unlockTime) {
            (bool success,) = msg.sender.call{ value: _am }("");
            if (success) {
                acc.balance -= _am;
                LogFile.AddMessage(msg.sender, _am, "Collect");
            }
        }
    }

    struct Holder {
        uint256 unlockTime;
        uint256 balance;
    }

    mapping(address => Holder) public Accounts;

    Log LogFile;

    uint256 public MinSum = 1 ether;

    constructor(address log) {
        LogFile = Log(log);
    }

    fallback() external payable {
        Deposit(0);
    }

    receive() external payable {
        Deposit(0);
    }
}

contract Log {
    event Message(address indexed Sender, string Data, uint256 Vai, uint256 Time);

    function AddMessage(address _adr, uint256 _val, string memory _data) external {
        emit Message(_adr, _data, _val, block.timestamp);
    }
}
