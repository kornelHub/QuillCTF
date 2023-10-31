// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {D31eg4t3} from "../src/D31eg4t3.sol";
import {D31eg4t3Attack} from "../src/D31eg4t3Attack.sol";

/*
1.Become the owner of the contract.
2.Make canYouHackMe mapping to true for your own address.
*/

/*
DelegateHack contract calls D31eg4t3 hackMe() with bites to execute changeOwner() in DelegateHacked
changeOwner() overrides D31eg4t3 because delegatecall() has been used.
A -> delegatecall() -> B
logic of contract B is executed with storage of contract A
*/

contract D31eg4t3Test is Test {
    D31eg4t3 public target;
    D31eg4t3Attack public attackContract;
    address owner;
    address attacker;

    function setUp() public {
        owner = makeAddr("owner");
        attacker = makeAddr("attacker");

        vm.prank(owner);
        target = new D31eg4t3();
    }

    function test_attack() public {
        // ATTACK
        vm.startPrank(attacker);
        attackContract = new D31eg4t3Attack();
        attackContract.attack(address(target));
        vm.stopPrank();

        // CHECK
        assertEq(target.owner(), attacker, "Attacker is not an owner");
        assertEq(target.canYouHackMe(attacker), true, "Contract is not hacked");
    }
}
