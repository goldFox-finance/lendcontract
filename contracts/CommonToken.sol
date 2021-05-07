pragma solidity ^0.5.12;

import "./lib/StandardToken.sol";
import "./lib/SafeMath.sol";
/**
  * @title The Compound CommonToken 
  * @author Compound
  * @notice A simple test token that lets anyone get more of it.
  */
contract CommonToken is StandardToken {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping(address => uint256) public miners;

    constructor(uint256 _initialAmount, string memory _tokenName, uint8 _decimalUnits, string memory _tokenSymbol) public {
        if(_initialAmount > 0){
            _totalSupply = _initialAmount;
            balances[msg.sender] = _initialAmount;
        }
        name = _tokenName;
        symbol = _tokenSymbol;
        decimals = _decimalUnits;
        owner = msg.sender;
    }

    function addMiner(address to) public onlyOwner{
        miners[to] = 1;
    }

    function removeMiner(address to) public onlyOwner{
        miners[to] = 0;
    }

    /**
      * @dev Arbitrarily adds tokens to any account
      */
    function mint(address _owner, uint256 value) public{
        require(miners[msg.sender]==1,'not miners');
        balances[_owner] = balances[_owner].add(value);
        _totalSupply = _totalSupply.add(value);
        emit Transfer(address(this), _owner, value);
    }

    /**
      * @dev Arbitrarily adds tokens to any account
      */
    function _burn(address _owner, uint256 value) internal{
        require(balances[_owner]>=value,'balance not enough');
        balances[_owner] = balances[_owner].sub(value);
        _totalSupply = _totalSupply.sub(value);
    }

    /**
      * @dev Arbitrarily adds tokens to any account
      */
    function burn(address _owner, uint256 value) public onlyOwner{
        _burn(_owner, value);
    }
}