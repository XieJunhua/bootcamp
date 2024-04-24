// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;


error WithdrawerNotManager();

contract Bank {
    address manager_address = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    mapping(address => uint256) amounts;
    address[] list;

    struct Result {
        address addre;
        uint256 amount;

    }

    event Received(address, uint);
    receive() external payable {
        save();
        emit Received(msg.sender, msg.value);
    } 

    //add money to my account
    function save() private {
        uint256 amount = msg.value;
        address sender = msg.sender;
        uint256 amount_temp = amounts[sender];
        uint256 amount_total = amount_temp + amount;
        amounts[sender] = amount_total;
        if(list.length < 3 ) { 
            if (list.length > 0 && list[list.length - 1] == sender) {
                list.pop();
            }
            list.push(sender);
        } else {
            // find the minimum value and the index
            uint256 index = 0;
            uint256 minValue = amounts[list[0]]; 
            for (uint i = 1; i < list.length; i++) {
                if (amounts[list[i]] <= minValue) {
                    index = i;
                    minValue = amounts[list[i]]; 
                }
            } 

            // compare the minimum value and the value of current account
            if (amounts[sender] >= minValue) {
                list[index] = sender;
            }
        }
    }

    function saveMoney() payable public {
        save();            
    }

    
    function queryMyAccount()public view returns (Result memory) {
        return Result(msg.sender, amounts[msg.sender]);
    }

    function listTop3Accounts()public view returns (address[] memory) {
        return list;
    }

    function withdraw()public{
        address sender = msg.sender;
        
        if (sender == manager_address) {
            payable(sender).transfer(address(this).balance);
        } else {
            revert WithdrawerNotManager();
        }
    }

    function queryAllBalance() public view returns (uint256) {
        return address(this).balance;
    }

}