// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {TrueXOR} from "../src/TrueXOR.sol";
import "forge-std/console.sol";

/**
WARNING! For this test to work pleas add following lines to foundry.toml in [profile.default] section
sender = '0x9dF0C6b0066D5317aA5b38B36850548DaCCa6B4e'
tx_origin = '0x9dF0C6b0066D5317aA5b38B36850548DaCCa6B4e'

This is because in foudry it isn't possible to change tx.origin address with prank() or startPrank()
*/

contract RoadClosedTest is Test {
    TrueXOR target;
    BoolGiver boolGiver;
    address attacker;

    function setUp() public {
        attacker = makeAddr("attacker");
        target = new TrueXOR();
        boolGiver = new BoolGiver();
    }

    function test_attack() public {
        vm.startPrank(attacker);

        assertTrue(target.callMe(address(boolGiver)));

        vm.stopPrank();
    }
}


contract BoolGiver {
    function giveBool() external view returns (bool) {
        return gasleft() % 2 == 0;
    }
}