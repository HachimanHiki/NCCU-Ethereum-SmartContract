pragma solidity ^0.4.24;

import "./Base.sol";

contract Loaner is Base{

    function guarantyETH(uint256 _oneEtherExchangeTokenRate, ERC20 _Token) public payable{
        uint256 numOfTokenSell = _oneEtherExchangeTokenRate * msg.value;
        require( _Token.balanceOf(address(this)) >= numOfTokenSell );

        guarantyEther[msg.sender].add(msg.value);
        borrowEther[msg.sender].add(msg.value);

        //_buyToken.transfer(0xC5E1b1c0BBb1587c7595Ec6deAe8e6BE6bBfbdF4, numOfTokenSell);
    }

    function sellETH(uint256 _oneEtherExchangeTokenRate, uint256 _saleValue, ERC20 _Token) public {
        uint256 numOfTokenBuy = _oneEtherExchangeTokenRate * _saleValue;

        tokenBalance[msg.sender][_Token].add(numOfTokenBuy);
        borrowEther[msg.sender].sub(_saleValue);
    }

    function liquidation(address _add) public {
        borrowEther[_add].sub(borrowEther[_add]);
    }
}