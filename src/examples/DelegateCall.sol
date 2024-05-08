// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract B {
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVars(uint256 _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }

    function collate_propagate_storage(bytes16 data) public payable {
        num = 1e5;
    }
}

contract A {
    uint256 public num;
    address public sender;
    uint256 public value;

    function setVarsDelegateCall(address _contract, uint256 _num) public payable {
        (bool success, bytes memory data) = _contract.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));
    }

    function setVarsCall(address _contract, uint256 _num) public payable {
        (bool success, bytes memory data) = _contract.call(abi.encodeWithSignature("setVars(uint256)", _num));
    }

    function delegeCallBurn(address _contract, uint256 _num) public payable {
        bytes16 h = 0x20010db8000000000000000000000001;
        (bool success, bytes memory data) = _contract.delegatecall(abi.encodeWithSignature("burn(uint256)", h));
    }
}

contract C {
    uint256 public value;
    uint256 public num;

    address public sender;

    function setVarsDelegateCall(address _contract, uint256 _num) public payable {
        (bool success, bytes memory data) = _contract.delegatecall(abi.encodeWithSignature("setVars(uint256)", _num));
    }

    function setVarsCall(address _contract, uint256 _num) public payable {
        (bool success, bytes memory data) = _contract.call(abi.encodeWithSignature("setVars(uint256)", _num));
    }
}
