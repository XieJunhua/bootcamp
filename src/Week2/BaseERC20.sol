// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

interface TokenRecipient {
    function tokenReceive(address _address, uint256 value, bytes memory extraData) external returns (bool);
}

error AmountExceedError(address _address);
error AllowancedExceedError(address _address);
error WithdrawError(address _address);
error InvalidAddressError(address _address);

contract BaseERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address _address => uint256 amount) internal balances;

    mapping(address _address => mapping(address approveAddress => uint256 amount)) internal allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(address _address) {
        name = "BaseERC20";
        symbol = "BERC20";
        decimals = 18;
        totalSupply = 100_000_000 * 10 ** 18;

        balances[_address] = totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        balance = balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value) {
            revert AmountExceedError(msg.sender);
        }
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferWithFallback(address _to, uint256 _value, bytes memory extraData) public returns (bool) {
        bool success = transfer(_to, _value);

        if (_to.code.length > 0) {
            // is conrtact
            success = TokenRecipient(_to).tokenReceive(msg.sender, _value, extraData);
        }
        return success;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (allowances[_from][msg.sender] >= _value) {
            revert AllowancedExceedError(msg.sender);
        }

        allowances[_from][msg.sender] = allowances[_from][msg.sender] - _value;

        if (balances[_from] >= _value) {
            revert AmountExceedError(_from);
        }

        balances[_from] = balances[_from] - _value;
        balances[_to] = balances[_to] + _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        remaining = allowances[_owner][_spender];
    }
}

contract TokenBank is TokenRecipient {
    mapping(address _address => uint256 amount) private accounts;
    address private tokenAddress;

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

    // function depositNew(uint256 value) public returns (bool) {
    //     bool result = BaseERC20(tokenAddress).transferWithFallback(address(this), value);

    //     if (result) {
    //         accounts[msg.sender] = accounts[msg.sender] + value;
    //         emit Log("save token success");
    //     }
    //     return result;
    // }

    function getAccounts() public view returns (uint256) {
        return accounts[msg.sender];
    }

    function withdraw(uint256 value) public {
        // require(value <= accounts[msg.sender], "you don't have enough money");
        if (value <= accounts[msg.sender]) {
            revert AmountExceedError(msg.sender);
        }

        address _address = msg.sender;
        accounts[_address] = accounts[_address] - value;
        bool success = BaseERC20(tokenAddress).transfer(_address, value);
        if (!success) {
            revert WithdrawError(msg.sender);
        }
    }

    function tokenReceive(address _address, uint256 value, bytes memory extraData) public returns (bool) {
        if (tokenAddress != msg.sender) {
            revert InvalidAddressError(_address);
        }
        accounts[_address] = accounts[_address] + value;
        return true;
    }
}
