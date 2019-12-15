pragma solidity 0.4.24;

import "./openzeppelin-solidity/ownership/Claimable.sol";
import "./openzeppelin-solidity/token/ERC20/ERC20.sol";
import "./openzeppelin-solidity/math/SafeMath.sol";

contract Base is Claimable{
    using SafeMath for uint256;

    ERC20 erc20Token;

    mapping(address => uint256) public etherBalance;
    mapping(address => uint256) public borrowEther;
    mapping(address => uint256) public lockedEther;
    mapping(address => mapping(address => uint256)) public tokenBalance;

    // now only support one ERC20 token
    constructor(address _erc20TokenAddress) public{
        erc20Token = ERC20(_erc20TokenAddress);
    }

    function getEtherBalance(address _add) public view returns (uint256) {
        return etherBalance[_add];
    }

    function getborrowEther(address _add) public view returns (uint256) {
        return borrowEther[_add];
    }

    function getLockedEtherBalance(address _add) public view returns (uint256) {
        return lockedEther[_add];
    }

    function getUnlockEtherBalance(address _add) public view returns (uint256) {
        return etherBalance[_add].sub(lockedEther[_add]);
    }

    function gettokenBalance(address _add, ERC20 _Token) public view returns (uint256) {
        return tokenBalance[_add][_Token];
    }
}