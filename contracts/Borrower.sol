pragma solidity ^0.4.24;

import "./Base.sol";

contract Borrower is Base{

    //event GuarantyETH (address indexed borrower, uint256 borrowValue);
    event GuarantyToken (address indexed borrower, uint256 borrowValue);

    function depositETHAndGuaranty(uint256 _oneEtherExchangeTokenRate, uint256 _value) public{
        require(erc20Token.approve(address(this), _value));
        erc20Token.transferFrom(msg.sender, address(this), _value);
        _guarantyETH(_oneEtherExchangeTokenRate, _value);
        tokenBalance[msg.sender][erc20Token] = tokenBalance[msg.sender][erc20Token].add(_value);
        //etherBalance[msg.sender] = etherBalance[msg.sender].add(_value);
    }

    function guarantyETH(uint256 _oneEtherExchangeTokenRate, uint256 _guarantyValue) public{
        require(tokenBalance[msg.sender][erc20Token] >= _guarantyValue);
        _guarantyETH(_oneEtherExchangeTokenRate, _guarantyValue);
    }

    function _guarantyETH(uint256 _oneEtherExchangeTokenRate, uint256 _guarantyValue) private{
        require(getLockedTokenBalance(msg.sender)==0);
        require(erc20Token.balanceOf(address(this)) >= _guarantyValue);

        lockedToken[msg.sender] = lockedToken[msg.sender].add(_guarantyValue);
        // num of ether buy
        borrowEther[msg.sender] = borrowEther[msg.sender].add(_guarantyValue.div(_oneEtherExchangeTokenRate));
        borrowInfo[msg.sender].initBorrowTime = now;
        borrowInfo[msg.sender].initBorrowRate = _oneEtherExchangeTokenRate;

        emit GuarantyToken(msg.sender, _guarantyValue);
    }

    event SellAllETH(address indexed borrower);
    event SellETH (address indexed borrower, uint256 sellValue);

    function sellETH(uint256 _oneEtherExchangeTokenRate, uint256 _saleValue) public {
        require(_oneEtherExchangeTokenRate > borrowInfo[msg.sender].initBorrowRate);

        uint256 numOfTokenBuy = _oneEtherExchangeTokenRate * _saleValue;
        uint256 principal = _saleValue.mul(borrowInfo[msg.sender].initBorrowRate);

        uint256 interestPayPerDay = principal.mul(interestRatePerDay).div(interestRatePerDayDecimals);
        uint256 borrowPeriod = (now.sub(borrowInfo[msg.sender].initBorrowTime)).div(1 days);
        uint256 remainToken = numOfTokenBuy.sub(interestPayPerDay.mul(borrowPeriod));

        if(remainToken > principal){
            tokenBalance[msg.sender][erc20Token] = tokenBalance[msg.sender][erc20Token].add(remainToken).sub(principal);
        }
        else{
            tokenBalance[msg.sender][erc20Token] = tokenBalance[msg.sender][erc20Token].add(principal).sub(remainToken);
            lockedToken[msg.sender] = lockedToken[msg.sender].add(principal).sub(remainToken);
        }

        borrowEther[msg.sender] = borrowEther[msg.sender].sub(_saleValue);

        // may have problem : borrowEther[msg.sender] ~= 0
        if (borrowEther[msg.sender] == 0){
            lockedToken[msg.sender] = lockedToken[msg.sender].sub(lockedToken[msg.sender]);
            borrowInfo[msg.sender].initBorrowTime = 0;
            borrowInfo[msg.sender].initBorrowRate = 0;

            emit SellAllETH(msg.sender);
        }

        emit SellETH(msg.sender, _saleValue);
    }
/*
    function depositETHAndGuaranty(uint256 _oneEtherExchangeTokenRate) public payable{
        _guarantyETH(_oneEtherExchangeTokenRate, msg.value);
        etherBalance[msg.sender] = etherBalance[msg.sender].add(msg.value);
    }

    function guarantyETH(uint256 _oneEtherExchangeTokenRate, uint256 _guarantyValue) public{
        require( getUnlockEtherBalance(msg.sender) >= _guarantyValue);
        _guarantyETH(_oneEtherExchangeTokenRate, _guarantyValue);
    }

    function _guarantyETH(uint256 _oneEtherExchangeTokenRate, uint256 _guarantyValue) private{
        require(getLockedEtherBalance(msg.sender)==0);
        uint256 numOfTokenSell = _oneEtherExchangeTokenRate.mul(_guarantyValue);
        require( erc20Token.balanceOf(address(this)) >= numOfTokenSell );

        lockedEther[msg.sender] = lockedEther[msg.sender].add(_guarantyValue);
        borrowEther[msg.sender] = borrowEther[msg.sender].add(_guarantyValue);
        borrowInfo[msg.sender].initBorrowTime = now;
        borrowInfo[msg.sender].initBorrowRate = _oneEtherExchangeTokenRate;

        emit GuarantyETH(msg.sender, _guarantyValue);
    }

    event SellAllETH(address indexed borrower);
    event SellETH (address indexed borrower, uint256 sellValue);

    function sellETH(uint256 _oneEtherExchangeTokenRate, uint256 _saleValue) public {
        uint256 numOfTokenBuy = _oneEtherExchangeTokenRate * _saleValue;
        uint256 interestPayPerDay = _saleValue.mul(borrowInfo[msg.sender].initBorrowRate)
        .mul(interestRatePerDay).div(interestRatePerDayDecimals );

        uint256 borrowPeriod = now.sub(borrowInfo[msg.sender].initBorrowTime).div(1 days);
        numOfTokenBuy = numOfTokenBuy.sub(interestPayPerDay.mul(borrowPeriod));

        tokenBalance[msg.sender][erc20Token] = tokenBalance[msg.sender][erc20Token].add(numOfTokenBuy);
        // borrow 100 token and win 105 , must return 100
        borrowEther[msg.sender] = borrowEther[msg.sender].sub(_saleValue);

        if (borrowEther[msg.sender] == 0){
            lockedEther[msg.sender] = lockedEther[msg.sender].sub(lockedEther[msg.sender]);
            borrowInfo[msg.sender].initBorrowTime = 0;
            borrowInfo[msg.sender].initBorrowRate = 0;

            emit SellAllETH(msg.sender);
        }

        emit SellETH(msg.sender, _saleValue);
    }
*/
    event Liquidation(address indexed borrower);

    function liquidation(address _add) public onlyOwner{
        borrowEther[_add] = borrowEther[_add].sub(borrowEther[_add]);
        emit Liquidation(_add);
    }
}