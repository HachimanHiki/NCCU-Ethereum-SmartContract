pragma solidity ^0.4.24;

import "./Base.sol";

contract Lender is Base{
    function lendERC20(uint256 _value) public{
        require(erc20Token.approve(address(this), _value));
        erc20Token.transferFrom(msg.sender, address(this), _value);
        tokenBalance[msg.sender][erc20Token] = tokenBalance[msg.sender][erc20Token].add(_value);
    }
}