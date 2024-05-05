// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.25 <0.9.0;

import { Test } from "forge-std/src/Test.sol";
import { console2 } from "forge-std/src/console2.sol";
import { TestVerify } from "../src/Week2/TestVerify.sol";

contract TestVerifyTest is Test {
    TestVerify testVerify;

    function setUp() public virtual {
        // Instantiate the contract-under-test.
        testVerify = new TestVerify();
    }

    function test_recovery() public {
        address alice = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
        vm.startPrank(alice);
        bytes memory a =
            hex"6607ace56239a99a715bc509ff201df13b3790ca7edfbefe61452120c60f12d51238e3aa0441da35d57c951b96df780ce61c276f94a588e1cf9f34b4a6d62a801c";

        console2.log(a.length);
        // console2.log(a);

        address result = testVerify.recover(hex"68656c6c6f", a);

        console2.log(result);
        // 0x4A1763Fa010fF68b7F2Cfe8c2A2c4F785AA2d49e 结果地址和remix上的不一致，需要人工校验
        // 消息不一样得到的地址结果还不一样，但是也能通过验证。
        // 定义一个bytes字面量是 hex"4A1763Fa010fF68b7F2Cfe8c2A2c4F785AA2d49e"
        vm.stopPrank();
    }
}
