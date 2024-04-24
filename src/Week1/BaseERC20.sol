// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) balances;

    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100_000_000 * 10 ** 18;

        balances[msg.sender] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        balance = balances[_owner];
        // write your code here
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        // write your code here
        require(balances[msg.sender] >= _value, "ERC20: transfer amount exceeds balance");
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        // write your code here
        // require(allowances[msg.sender][_from] >= _value, "ERC20: transfer amount exceeds allowance");
        require(allowances[_from][msg.sender] >= _value, "ERC20: transfer amount exceeds allowance");

        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _value;
        // transfer(_to, _value);
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");

        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        // write your code here

        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        // write your code here
        remaining = allowances[_owner][_spender];
    }
}

contract TokenBank {
    mapping(address => uint256) accounts;
    address tokenAddress;

    event Log(string);
    event Print(string, address);

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
    }

    function deposit(uint256 value) public {
        bool result = BaseERC20(tokenAddress).transferFrom(msg.sender, address(this), value);

        if (result) {
            accounts[msg.sender] = accounts[msg.sender] + value;
            emit Log("save token success");
        }
    }

    function getAccounts() public view returns (uint256) {
        return accounts[msg.sender];
    }

    function withdraw(uint256 value) public {
        require(value <= accounts[msg.sender], "you don't have enough money");
        bool success = BaseERC20(tokenAddress).transfer(msg.sender, value);
        if (success) {
            accounts[msg.sender] = accounts[msg.sender] - value;
        }
    }
}
