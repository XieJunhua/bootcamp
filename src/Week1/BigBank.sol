// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;


error WithdrawerNotManager(address, address);

contract Bank {
    address manager_address = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    mapping(address => uint256) amounts;
    address[] list;

    struct Result {
        address addre;
        uint256 amount;

    }

    event Received(address, uint);
    event addresses(string, address, address);
    receive() external payable virtual  {
        save();
        emit Received(msg.sender, msg.value);
    } 

    //add money to my account
    function save() internal virtual  {
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

    function withdraw()public virtual {
        address sender = msg.sender;

        emit addresses("final call", sender, manager_address);
        
        if (sender == getManagerAddress()) {
            payable(sender).transfer(address(this).balance);
        } else {
            revert WithdrawerNotManager(sender, manager_address);
        }
    }

    function queryAllBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getManagerAddress() public view returns (address) {
        return manager_address;
    }

}

contract BigBank is Bank {

    modifier receiveThreshold{
        require(msg.value > 0.001 ether);
        _;
    }

    function save() internal override receiveThreshold {
        super.save();
    }

    function withdraw() public override{
        super.withdraw();

    }

    function changeManager(address _address) public {
        manager_address = _address;
    }  
}

contract Ownable{

    address bankAddress;
    event Log(address, string);

    event PrintDoubleAddress(address, address);

    constructor(address _address) {
        bankAddress = _address;
    }

    function withdraw() public  {
        emit Log(msg.sender, "init_address_withdraw");

        BigBank bb = BigBank(payable(bankAddress));
        bb.queryAllBalance();


        bb.withdraw();
        emit Log(msg.sender, "return address_withdraw");
        
    }

    // 如果没有定义receive方法，那么其他合约向这个合约地址转账的时候会报错
    receive() external payable { }

}
