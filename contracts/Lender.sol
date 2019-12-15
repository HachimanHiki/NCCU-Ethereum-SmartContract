pragma solidity ^0.4.24;

import "./Base.sol";

contract Lender is Base{
    function lendERC20(uint256 _value, ERC20 lendToken) public{
        require(lendToken.approve(address(this), _value));
        lendToken.transferFrom(msg.sender, address(this), _value);
        tokenBalance[msg.sender][lendToken] = tokenBalance[msg.sender][lendToken].add(_value);
    }
}