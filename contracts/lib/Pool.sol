pragma solidity >=0.5.0 <0.8.0;

import "./ERC20.sol";
import "./owner.sol";

contract Pool is Owner{
    uint256 public accSupplyPerShare;
    uint256 public accBorrowPerShare;
    uint256 public lastSupplyRewardBlock;
    uint256 public lastBorrowRewardBlock;
    ERC20 public gfc;
    uint256 public supplyPerBlock = 1e18;
    uint256 public borrowPerBlock = 1e18;
    uint256 public constant ACC_PRECISION = 1e12;

    function setSupplyPerBlock(uint256 _perBlock) public onlyOwner{
        supplyPerBlock = _perBlock;
    }

    function setBorrowPerBlock(uint256 _perBlock) public onlyOwner{
        borrowPerBlock = _perBlock;
    }

}