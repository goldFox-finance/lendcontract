pragma solidity >=0.5.0 <0.8.0;

import "./lib/ERC20Basic.sol";
import "./MarketInterface.sol";
import "./lib/SafeMath.sol";
import './lib/Babylonian.sol';
import './lib/FixedPoint.sol';
import './lib/UniswapV2OracleLibrary.sol';
import './interfaces/IUniswapV2Pair.sol';
import './interfaces/IUniswapV2Factory.sol';


contract Controller {
    using SafeMath for uint256;

    // uniswap
    address public usdt;
    // uniswap
    address public factory;

    // oracle

    address public owner;

    address public operator;
    
    mapping (address => bool) public markets;
    mapping (address => address) public marketsByToken;
    mapping (address => uint) public prices;

    address[] public marketList;

    uint public collateralFactor;
    uint public liquidationFactor;
    uint public constant MANTISSA = 1e6;
    uint public unit = 1e6;
    constructor(address _factory,address _usdt,address _operator) public {
        owner = msg.sender;
        usdt = _usdt;
        factory = _factory;
        operator = _operator;
    }

    modifier onlyOperator() {
        require(msg.sender == operator);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyMarket() {
        require(markets[msg.sender]);
        _;
    }

    function marketListSize() public view returns (uint) {
      return marketList.length;
    }

    function setCollateralFactor(uint factor) public onlyOperator {
        collateralFactor = factor;
    }

    function setLiquidationFactor(uint factor) public onlyOwner {
        liquidationFactor = factor;
    }

    // 喂价 或者是通过uni 获得实时价格
    function setPrice(address market, uint price) public onlyOperator {
        require(market != address(0) , 'ADDRESS ERROR!!!');
        require(markets[market]);

        prices[market] = price;
    }

    function pairFor(MarketInterface market) public view returns(address){
        return IUniswapV2Factory(factory).getPair(market.token(), usdt);
    }

    function getDecimal(address t) public view returns(uint256){
        require(t != address(0) , 'ADDRESS ERROR!!!');
        return 10 ** uint256(IERC20(t).decimals());
    }

    function getPrice(MarketInterface market) public view returns(uint256){
        IUniswapV2Pair _pair =
            IUniswapV2Pair(
                IUniswapV2Factory(factory).getPair(market.token(), usdt)
            );
        if(address(0)==address(_pair)){
            return prices[address(market)];
        }
        // 从uni获取价格 或者预言机 单位USDT
        (uint256 reserve0, uint256 reserve1, ) = _pair.getReserves();
        if(reserve0 <= 0 || reserve1 <= 0){
            return prices[address(market)];
        }
        uint256 token0Decimal = 10 ** uint256(IERC20(_pair.token0()).decimals());
        uint256 token1Decimal = 10 ** uint256(IERC20(_pair.token1()).decimals());
        if (market.token() == _pair.token0()) {
            return reserve1.mul(token0Decimal).mul(unit).div(reserve0).div(token1Decimal);
        }
        return reserve0.mul(token1Decimal).mul(unit).div(reserve1).div(token0Decimal);
    }

    function addMarket(address market) public onlyOwner {
        require(market != address(0) , 'ADDRESS ERROR!!!');
        address marketToken = MarketInterface(market).token();
        require(marketsByToken[marketToken] == address(0));
        markets[market] = true;
        marketsByToken[marketToken] = market;
        marketList.push(market);
    }

    function getAccountLiquidity(address account) public view returns (uint) {
        require(account != address(0) , 'ADDRESS ERROR!!!');
        uint liquidity = 0;

        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = getAccountValues(account);

        borrowValue = borrowValue.mul(collateralFactor.add(MANTISSA));
        borrowValue = borrowValue.div(MANTISSA);

        if (borrowValue < supplyValue)
            liquidity = supplyValue.sub(borrowValue);

        return liquidity;
    }

    function getAccountHealth(address account) public view returns (uint) {
        require(account != address(0) , 'ADDRESS ERROR!!!');
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = getAccountValues(account);

        return calculateHealthIndex(supplyValue, borrowValue);
    }
    
    function calculateHealthIndex(uint supplyValue, uint borrowValue) internal view returns (uint) {
        if (supplyValue == 0 || borrowValue == 0)
            return 0;

        borrowValue = borrowValue.mul(liquidationFactor.add(MANTISSA));
        borrowValue = borrowValue.div(MANTISSA);
        
        return supplyValue.mul(MANTISSA).div(borrowValue);
    }

    function getAccountValues(address account) public view returns (uint supplyValue, uint borrowValue) {
        require(account != address(0) , 'ADDRESS ERROR!!!');
        for (uint k = 0; k < marketList.length; k++) {
            MarketInterface market = MarketInterface(marketList[k]);
            uint price = getPrice(MarketInterface(marketList[k]));
            
            supplyValue = supplyValue.add(market.updatedSupplyOf(account).mul(price));
            borrowValue = borrowValue.add(market.updatedBorrowBy(account).mul(price));
        }
    }
    
    function liquidateCollateral(address borrower, address liquidator, uint amount, MarketInterface collateralMarket) public onlyMarket returns (uint collateralAmount)  {
        require(borrower != address(0) , 'ADDRESS ERROR!!!');
        require(liquidator != address(0) , 'ADDRESS ERROR!!!');
        uint price = getPrice(MarketInterface(msg.sender));        
        require(price > 0);

        uint collateralPrice = getPrice(collateralMarket);        
        require(collateralPrice > 0);
        
        uint supplyValue;
        uint borrowValue;

        (supplyValue, borrowValue) = getAccountValues(borrower);
        require(borrowValue > 0);
        
        uint healthIndex = calculateHealthIndex(supplyValue, borrowValue);
        
        require(healthIndex <= MANTISSA);
        
        uint liquidationValue = amount.mul(price).div(unit);
        uint liquidationPercentage = liquidationValue.mul(MANTISSA).div(borrowValue);
        uint collateralValue = supplyValue.mul(liquidationPercentage).div(MANTISSA);
        
        collateralAmount = collateralValue.mul(unit).div(collateralPrice);
        
        collateralMarket.transferTo(borrower, liquidator, collateralAmount);
    }
}

