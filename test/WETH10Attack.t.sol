// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {WETH10} from "../src/WETH10.sol";
import {WETH10Attack} from "../src/WETH10Attack.sol";

/*
The contract currently has 10 ethers. (Check the Foundry configuration.)
You are Bob (the White Hat). 
Your job is to rescue all the funds from the contract, starting with 1 ether, in only one transaction.
*/

/*
BOB = weth10Attack
Attack plan
1. Get approve for unlimited amount of WETH10 token using execute() function
2. Deposit X ETH with deposit() from WETH10.
3. Call withdrawAll(), X ETH is transfer to WETH10Attack, on receive() we transfer WETH10 token to
  WETH10 contract (later we can transfer them back, cuz we have unlimited approval). Using this
  0 tokens are burned in _burnAll() function (amount of token to burn is taken from balanceOf(msg.sender)).
4. Using transferFrom() we get back X WETH10 tokens.
5. Using withdrawAll() we exchange X WETH10 to X ETH.
6. We end up with 2X ETH. Go back to 2. point to extract all possible funds from WETH10 contract 
*/

contract Weth10Test is Test {
    WETH10 public weth;
    WETH10Attack public attackContract;
    address owner;
    address bob;

    function setUp() public {
        weth = new WETH10();
        bob = makeAddr("bob");

        vm.deal(address(weth), 10 ether);
        vm.deal(address(bob), 1 ether);
    }

    function testHack() public {
        assertEq(address(weth).balance, 10 ether, "weth contract should have 10 ether");

        vm.startPrank(bob);
        attackContract = new WETH10Attack{value: 1 ether}(bob);
        attackContract.attack(address(weth));
        vm.stopPrank();


        assertEq(address(weth).balance, 0, "empty weth contract");
        assertEq(bob.balance, 11 ether, "player should end with 11 ether");
    }
}