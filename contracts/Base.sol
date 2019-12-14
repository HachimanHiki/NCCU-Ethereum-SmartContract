pragma solidity 0.4.24;

import "./openzeppelin-solidity/ownership/Claimable.sol";
import "./openzeppelin-solidity/token/ERC20/ERC20.sol";
import "./openzeppelin-solidity/math/SafeMath.sol";

contract Base is Claimable{
    using SafeMath for uint256;
    mapping(address => uint256) public guarantyEther;
    mapping(address => uint256) public borrowEther;
    mapping(address => mapping(address => uint256)) public tokenBalance;

    function getGuarantyEther(address _add) public view returns (uint256) {
        return guarantyEther[_add];
    }

    function getborrowEther(address _add) public view returns (uint256) {
        return borrowEther[_add];
    }

    function gettokenBalance(address _add, ERC20 _Token) public view returns (uint256) {
        return tokenBalance[_add][_Token];
    }
}