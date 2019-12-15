pragma solidity 0.4.24;

import "./Loaner.sol";
import "./Lender.sol";

contract Defi is Lender, Loaner{
    // user withdraw
    function withdrawEther(uint256 value) public{
        require(getUnlockEtherBalance(msg.sender) >= value);
        address(this).transfer(value);
    }

    function withdrawERC20(uint256 value, ERC20 withdrawToken) public{
        require(tokenBalance[msg.sender][withdrawToken] >= value);
        tokenBalance[msg.sender][withdrawToken] = tokenBalance[msg.sender][withdrawToken].sub(value);
        withdrawToken.transfer(msg.sender, value);
    }

    // admin test
    function adminWithdrawERC20(ERC20 withdrawToken) public onlyOwner{
        withdrawToken.transfer(msg.sender, withdrawToken.balanceOf(address(this)));
    }

}