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

            if (n.value < msg.value) {
                nodes[msg.sender] = Node(head, msg.value, msg.sender);
                head = msg.sender;
                return;
            }

            while (n.next != address(0)) {
                if (msg.value > nodes[n.next].value) {
                    nodes[msg.sender] = Node(n.next, msg.value, msg.sender);
                    nodes[n.depositer].next = msg.sender;
                    return;
                }
                n = nodes[n.next];
            }

            if (n.next == address(0)) {
                nodes[msg.sender] = Node(address(0), msg.value, msg.sender);
                nodes[n.depositer].next = msg.sender;
                return;
            }
        }
    }
}
