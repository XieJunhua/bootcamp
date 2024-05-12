// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Bank {
    struct Node {
        address next;
        uint256 value;
        address depositer;
    }

    mapping(address => Node) public nodes;
    address public head; // this is a sorted linked list

    function deposit() external payable {
        if (head == address(0)) {
            nodes[msg.sender] = Node(address(0), msg.value, msg.sender);
            head = msg.sender;
        } else {
            Node memory n = nodes[head];

            uint256 amountValue = nodes[msg.sender].value + msg.value;

            if (n.value < amountValue) {
                nodes[msg.sender] = Node(head, amountValue, msg.sender);
                head = msg.sender;
                return;
            }

            while (n.next != address(0)) {
                if (amountValue > nodes[n.next].value) {
                    nodes[msg.sender] = Node(n.next, amountValue, msg.sender);
                    nodes[n.depositer].next = msg.sender;
                    return;
                }
                n = nodes[n.next];
            }

            if (n.next == address(0)) {
                nodes[msg.sender] = Node(address(0), amountValue, msg.sender);
                nodes[n.depositer].next = msg.sender;
                return;
            }
        }
    }
}
