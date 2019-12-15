pragma solidity 0.4.24;

import "./Loaner.sol";
import "./Lender.sol";

contract Defi is Lender, Loaner{
    // user withdraw
    function withdrawEther(uint256 value) public{
        require(getUnlockEtherBalance(msg.sender) >= value);
        address(this).transfer(value);
    }

    function withdrawERC20(uint256 value) public{
        require(tokenBalance[msg.sender][erc20Token] >= value);
        tokenBalance[msg.sender][erc20Token] = tokenBalance[msg.sender][erc20Token].sub(value);
        erc20Token.transfer(msg.sender, value);
    }

    // admin test
    function adminWithdrawERC20() public onlyOwner{
        erc20Token.transfer(msg.sender, erc20Token.balanceOf(address(this)));
    }

    /*
    function adminWithdrawERC20(ERC20 withdrawToken) public onlyOwner{
        withdrawToken.transfer(msg.sender, withdrawToken.balanceOf(address(this)));
    }
    */
}