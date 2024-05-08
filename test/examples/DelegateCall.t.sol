// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test, console2 } from "forge-std/src/Test.sol";
import { A, B, C } from "../../src/examples/DelegateCall.sol";

contract DelegateCallTest is Test {
    A a;
    B b;
    C c;
    address alice = makeAddr("alice");

    function setUp() public {
        a = new A();
        b = new B();
        c = new C();
    }

    function testCall() public {
        vm.startPrank(alice);
        vm.deal(alice, 1 ether);
        a.setVarsCall{ value: 1 ether }(address(b), 11); // call setVars by call
        assertEq(b.num(), 11);
        assertEq(b.sender() == address(a), true); // the msg.sender in contract b is a, is not alice
        assertEq(b.value(), 0); // contract b will not receive any ether

        vm.stopPrank();
    }

    function testDelegateCall() public {
        vm.startPrank(alice);
        vm.deal(alice, 1 ether);
        a.setVarsDelegateCall{ value: 1 ether }(address(b), 11); // call setVars by call
        console2.log("value from contact b ----------");
        console2.log(b.num());
        console2.log(b.sender());
        console2.log(b.value());
        console2.log("------------");
        // all the value in the contact b will not change
        // 实际上仅仅改变的是contract a中的值，相当于是把合约b中的function提到a中来执行,
        // 所以就需要两个合约中的存储结构是一致的。因为合约a执行合约b中的方法的时候对变量进行修改是按照变量在b中的槽位来进行修改

        assertEq(a.num(), 11);
        assertEq(a.sender(), alice); // the msg.sender in contract b is a, is not alice
        assertEq(a.value(), 1 ether); // contract b will not receive any ether
        vm.stopPrank();
    }

    function testDelegateCallNameConfict() public {
        vm.startPrank(alice);
        vm.deal(alice, 1 ether);
        a.delegeCallBurn{ value: 1 ether }(address(b), 11); // call setVars by call
        console2.log("value from contact b ----------");
        console2.log(b.num());
        console2.log(b.sender());
        console2.log(b.value());
        console2.log("------------");
        // all the value in the contact b will not change
        // 实际上仅仅改变的是contract a中的值，相当于是把合约b中的function提到a中来执行,
        // 所以就需要两个合约中的存储结构是一致的。因为合约a执行合约b中的方法的时候对变量进行修改是按照变量在b中的槽位来进行修改

        // 可以通过合约代码看到，用户可能以为调用的是burn方法，其实通过代理调用的并不是burn方法，而是collate_propagate_storage(bytes16)
        // 这是因为函数签名发生了冲突，函数签名是取该函数hash的前4位，而delegatecall是通过函数签名的方式去对应合约地址中寻找函数，导致找到的函数有可能不是我们想要的
        console2.log("value from contact b ----------");
        console2.log(a.num());
        console2.log(a.sender());
        console2.log(a.value());
        console2.log("------------");

        vm.stopPrank();
    }

    function testCDelegateCall() public {
        vm.startPrank(alice);
        vm.deal(alice, 1 ether);
        c.setVarsDelegateCall{ value: 1 ether }(address(b), 11); // call setVars by call
        console2.log("value from contact b ----------");
        console2.log(b.num());
        console2.log(b.sender());
        console2.log(b.value());
        console2.log("------------");
        // all the value in the contact b will not change
        // 实际上仅仅改变的是contract a中的值，相当于是把合约b中的function提到a中来执行,
        // 所以就需要两个合约中的存储结构是一致的。因为合约a执行合约b中的方法的时候对变量进行修改是按照变量在b中的槽位来进行修改
        // 当合约C的布局和合约b的布局不一致的时候，就会出现问题，因为合约C中的变量在b中的槽位不一致
        // delegatecall执行的方法会按照合约b中的槽位给c中的变量进行复制
        console2.log("value from contact c ----------");
        console2.log(c.num());
        console2.log(c.sender());
        console2.log(c.value());
        console2.log("------------");
        vm.stopPrank();
    }
}
