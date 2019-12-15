pragma solidity ^0.4.24;

import "./Base.sol";

contract Loaner is Base{

    event GuarantyETH (address indexed loaner, uint256 loanValue);

    function depositETHAndGuaranty(uint256 _oneEtherExchangeTokenRate) public payable{
        uint256 numOfTokenSell = _oneEtherExchangeTokenRate * msg.value;
        require( erc20Token.balanceOf(address(this)) >= numOfTokenSell );

        etherBalance[msg.sender] = etherBalance[msg.sender].add(msg.value);
        lockedEther[msg.sender] = lockedEther[msg.sender].add(msg.value);
        borrowEther[msg.sender] = borrowEther[msg.sender].add(msg.value);
        borrowInfo[msg.sender].initBorrowTime = now;
        borrowInfo[msg.sender].initBorrowRate = _oneEtherExchangeTokenRate;

        emit GuarantyETH(msg.sender, msg.value);
        //_buyToken.transfer(0xC5E1b1c0BBb1587c7595Ec6deAe8e6BE6bBfbdF4, numOfTokenSell);
    }

    function guarantyETH(uint256 _oneEtherExchangeTokenRate, uint256 _guarantyValue) public{
        uint256 numOfTokenSell = _oneEtherExchangeTokenRate * _guarantyValue;
        require( erc20Token.balanceOf(address(this)) >= numOfTokenSell );

        require( getUnlockEtherBalance(msg.sender) >= _guarantyValue);
        lockedEther[msg.sender] = lockedEther[msg.sender].add(_guarantyValue);
        borrowEther[msg.sender] = borrowEther[msg.sender].add(_guarantyValue);
        borrowInfo[msg.sender].initBorrowTime = now;
        borrowInfo[msg.sender].initBorrowRate = _oneEtherExchangeTokenRate;

        emit GuarantyETH(msg.sender, _guarantyValue);
    }

    event SellAllETH(address indexed loaner);
    event SellETH (address indexed loaner, uint256 sellValue);

    function sellETH(uint256 _oneEtherExchangeTokenRate, uint256 _saleValue) public {
        uint256 numOfTokenBuy = _oneEtherExchangeTokenRate * _saleValue;
        uint256 interestPayPerDay = _saleValue.mul( borrowInfo[msg.sender].initBorrowRate).mul(interestRatePerDay).div(interestRatePerDayDecimals );
        uint256 borrowPeriod = now.sub(borrowInfo[msg.sender].initBorrowTime).div(1 days);
        numOfTokenBuy = numOfTokenBuy.sub( interestPayPerDay.mul(borrowPeriod) );

        tokenBalance[msg.sender][erc20Token] = tokenBalance[msg.sender][erc20Token].add(numOfTokenBuy);
        borrowEther[msg.sender] = borrowEther[msg.sender].sub(_saleValue);
        if (borrowEther[msg.sender] == 0){
            lockedEther[msg.sender] = lockedEther[msg.sender].sub(lockedEther[msg.sender]);
            emit SellAllETH(msg.sender);
        }

        emit SellETH(msg.sender, _saleValue);
    }

    event Liquidation(address indexed loaner);

    function liquidation(address _add) public onlyOwner{
        borrowEther[_add] = borrowEther[_add].sub(borrowEther[_add]);
        emit Liquidation(_add);
    }
}