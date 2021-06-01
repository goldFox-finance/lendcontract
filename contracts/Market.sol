pragma solidity >=0.5.0 <0.8.0;

import "./lib/ERC20.sol";
import "./Controller.sol";
import "./lib/SafeMath.sol";

contract Market is MarketInterface {
    using SafeMath for uint256;

    address public owner;

    ERC20 public token;
    Controller public controller;

    uint256 public totalSupply;

    uint256 public supplyIndex;

    uint256 public accrualBlockNumber;
    ERC20 public gfc;
    uint256 public lendRate;
    uint256 public borrowIndex;
    uint256 public totalBorrows;
    uint256 public baseBorrowRate;
    uint256 public utilizationRateFraction;
    
    uint256 public blocksPerYear;
    address public devaddr;
    struct SupplySnapshot {
        uint256 supply;
        uint256 interestIndex;
    }

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    mapping (address => SupplySnapshot) supplies;
    mapping (address => BorrowSnapshot) borrows;

    uint256 public constant FACTOR = 1e18;

    event Supply(address user, uint256 amount);
    event Redeem(address user, uint256 amount);
    event Borrow(address user, uint256 amount);
    event PayBorrow(address user, uint256 amount);
    event LiquidateBorrow(address borrower, uint256 amount, address liquidator, address collateralMarket, uint256 collateralAmount);

    constructor(ERC20 _token,ERC20 _gfc,uint256 _lendRate, uint256 _baseBorrowAnnualRate, uint256 _blocksPerYear, uint256 _utilizationRateFraction,address _devaddr) public {
        require(ERC20(_token).totalSupply() >= 0);
        owner = msg.sender;
        token = _token;
        borrowIndex = FACTOR;
        supplyIndex = FACTOR;
        blocksPerYear = _blocksPerYear;
        baseBorrowRate = _baseBorrowAnnualRate.div(_blocksPerYear);
        accrualBlockNumber = block.number;
        devaddr = _devaddr;
        utilizationRateFraction = _utilizationRateFraction.mul(FACTOR).div(_blocksPerYear);
        gfc = _gfc;
        lendRate = _lendRate;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyController() {
        require(msg.sender == address(controller));
        _;
    }

    function setUtilizationRateFraction(uint256 _utilizationRateFraction) public onlyOwner{
        utilizationRateFraction = _utilizationRateFraction;
    }

    function setBlocksPerYear(uint256 _blocksPerYear) public onlyOwner{
        blocksPerYear = _blocksPerYear;
    }

    function setGfc(ERC20 _gfc) public{
        gfc = _gfc;
    }


    function setLendRate(uint256 _lendRate) public{
        lendRate = _lendRate;
    }

    function getLendGfc(uint256 _amount) public view returns(uint256){
        uint256 cprice = controller.getPrice(this);
        uint256 amount = _amount.mul(cprice).mul(1e18).div(controller.unit()).mul(lendRate).div(10000);
        uint256 gprice = controller.getInternalPrice(address(gfc));
        return amount.mul(controller.unit()).div(gprice).div(1e18);
    }


    function getCash() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function utilizationRate(uint256 cash, uint256 borrowed, uint256 reserves) public pure returns (uint256) {
        if (borrowed == 0)
            return 0;
        // 利息计算 = 借款 / (存款+借款-存款准备金)
        return borrowed.mul(FACTOR).div(cash.add(borrowed).sub(reserves));
    }

    function getBorrowRate(uint256 cash, uint256 borrowed, uint256 reserves) public view returns (uint256) {
        uint256 ur = utilizationRate(cash, borrowed, reserves);
        // 借款利率
        return ur.mul(utilizationRateFraction).div(FACTOR).add(baseBorrowRate);
    }

    function getSupplyRate(uint256 cash, uint256 borrowed, uint256 reserves) public view returns (uint256) {
        uint256 borrowRate = getBorrowRate(cash, borrowed, reserves);
        // 存款利率
        return utilizationRate(cash, borrowed, reserves).mul(borrowRate).div(FACTOR);
    }

    // 每一个区块的借款利率
    function borrowRatePerBlock() public view returns (uint256) {
        return getBorrowRate(getCash(), totalBorrows, 0);
    }

   // 每一个区块的存款利率
    function supplyRatePerBlock() public view returns (uint256) {
        return getSupplyRate(getCash(), totalBorrows, 0);
    }

    // 存款本金
    function supplyOf(address user) public view returns (uint256) {
        return supplies[user].supply;
    }

    // 存款本金
    function balanceOf(address user) public view returns (uint256) {
        return supplies[user].supply;
    }
    // 借款额
    function borrowBy(address user) public view returns (uint256) {
        return borrows[user].principal;
    }

    function updatedBorrowBy(address user) public view returns (uint256) {
        BorrowSnapshot storage snapshot = borrows[user];

        if (snapshot.principal == 0)
            return 0;

        uint256 newTotalBorrows;
        uint256 newBorrowIndex;

        (newTotalBorrows, newBorrowIndex) = calculateBorrowDataAtBlock(block.number);

        return snapshot.principal.mul(newBorrowIndex).div(snapshot.interestIndex);
    }

    function updatedSupplyOf(address user) public view returns (uint256) {
        SupplySnapshot storage snapshot = supplies[user];

        if (snapshot.supply == 0)
            return 0;

        uint256 newTotalSupply;
        uint256 newSupplyIndex;

        (newTotalSupply, newSupplyIndex) = calculateSupplyDataAtBlock(block.number);

        return snapshot.supply.mul(newSupplyIndex).div(snapshot.interestIndex);
    }

    function setController(Controller _controller) public onlyOwner {
        controller = _controller;
    }

    function supply(uint256 amount) public {
        supplyInternal(msg.sender, amount);

        emit Supply(msg.sender, amount);
    }

    function mint(uint256 amount) public {
        supplyInternal(msg.sender, amount);

        emit Supply(msg.sender, amount);
    }

    function supplyInternal(address supplier, uint256 amount) internal {
        // TODO check msg.sender != this
        require(token.transferFrom(supplier, address(this), amount), "No enough tokens");

        accrueInterest();

        SupplySnapshot storage supplySnapshot = supplies[supplier];

        supplySnapshot.supply = updatedSupplyOf(supplier);
        supplies[supplier].supply = supplies[supplier].supply.add(amount);
        supplies[supplier].interestIndex = supplyIndex;

        totalSupply = totalSupply.add(amount);
    }

    function redeem(uint256 amount) public {
        redeemInternal(msg.sender, msg.sender, amount);

        uint256 supplierSupplyValue;
        uint256 supplierBorrowValue;

        (supplierSupplyValue, supplierBorrowValue) = controller.getAccountValues(msg.sender);

        require(supplierSupplyValue >= supplierBorrowValue.mul(controller.MANTISSA().add(controller.collateralFactor())).div(controller.MANTISSA()),'流动性不足!');

        emit Redeem(msg.sender, amount);
    }

    function redeemInternal(address supplier, address receiver, uint256 amount) internal {
        require(token.balanceOf(address(this)) >= amount);

        accrueInterest();

        SupplySnapshot storage supplySnapshot = supplies[supplier];
        uint256 currentsupply = updatedSupplyOf(supplier);
        supplySnapshot.supply = currentsupply;
        
        supplies[supplier].interestIndex = supplyIndex;

        require(supplySnapshot.supply >= amount, "No enough supply");

        require(token.transfer(receiver, amount), "No enough tokens");
        if(supplySnapshot.supply >amount){
            supplySnapshot.supply = supplySnapshot.supply.sub(amount);
        } else{
            supplySnapshot.supply = 0;
        }
        if(totalSupply > amount){
            totalSupply = totalSupply.sub(amount);
        } else{
            totalSupply = 0;
        }
    }

    function borrow(uint256 amount) public {
        gfc.transferFrom(msg.sender, address(this), getLendGfc(amount));
        require(token.balanceOf(address(this)) >= amount);

        accrueInterest();

        BorrowSnapshot storage borrowSnapshot = borrows[msg.sender];

        if (borrowSnapshot.principal > 0) {
            uint256 interest = borrowSnapshot.principal.mul(borrowIndex).div(borrowSnapshot.interestIndex).sub(borrowSnapshot.principal);

            borrowSnapshot.principal = borrowSnapshot.principal.add(interest);
            borrowSnapshot.interestIndex = borrowIndex;
        }
        uint256 cprice = controller.getPrice(this);
        require(controller.getAccountLiquidity(msg.sender) >= cprice.mul(amount).mul(2).div(controller.unit()), "Not enough account liquidity");

        require(token.transfer(msg.sender, amount), "No enough tokens to borrow");

        borrowSnapshot.principal = borrowSnapshot.principal.add(amount);
        borrowSnapshot.interestIndex = borrowIndex;

        totalBorrows = totalBorrows.add(amount);
        
        emit Borrow(msg.sender, amount);
    }

    function accrueInterest() public {
        uint256 currentBlockNumber = block.number;

        (totalBorrows, borrowIndex) = calculateBorrowDataAtBlock(currentBlockNumber);
        (totalSupply, supplyIndex) = calculateSupplyDataAtBlock(currentBlockNumber);

        accrualBlockNumber = currentBlockNumber;
    }

    function calculateBorrowDataAtBlock(uint256 newBlockNumber) internal view returns (uint256 newTotalBorrows, uint256 newBorrowIndex) {
        if (newBlockNumber <= accrualBlockNumber)
            return (totalBorrows, borrowIndex);

        if (totalBorrows == 0)
            return (totalBorrows, borrowIndex);

        uint256 blockDelta = newBlockNumber - accrualBlockNumber;
        // 这么多区块的总利息率
        uint256 simpleInterestFactor = borrowRatePerBlock().mul(blockDelta);
        // 这么多区块的总利息
        uint256 interestAccumulated = simpleInterestFactor.mul(totalBorrows).div(FACTOR);

        newBorrowIndex = simpleInterestFactor.mul(borrowIndex).div(FACTOR).add(borrowIndex);
        newTotalBorrows = interestAccumulated.add(totalBorrows);
    }

    function calculateSupplyDataAtBlock(uint256 newBlockNumber) internal view returns (uint256 newTotalSupply, uint256 newSupplyIndex) {
        if (newBlockNumber <= accrualBlockNumber)
            return (totalSupply, supplyIndex);

        if (totalSupply == 0)
            return (totalSupply, supplyIndex);

        uint256 blockDelta = newBlockNumber - accrualBlockNumber;

        uint256 simpleInterestFactor = supplyRatePerBlock().mul(blockDelta);
        uint256 interestAccumulated = simpleInterestFactor.mul(totalSupply).div(FACTOR);

        newSupplyIndex = simpleInterestFactor.mul(supplyIndex).div(FACTOR).add(supplyIndex);
        newTotalSupply = interestAccumulated.add(totalSupply);
    }

    function getUpdatedTotalBorrows() public view returns (uint256) {
        uint256 newTotalBorrows;
        uint256 newBorrowIndex;

        (newTotalBorrows, newBorrowIndex) = calculateBorrowDataAtBlock(block.number);

        return newTotalBorrows;
    }

    function getUpdatedTotalSupply() public view returns (uint256) {
        uint256 newTotalSupply;
        uint256 newSupplyIndex;

        (newTotalSupply, newSupplyIndex) = calculateSupplyDataAtBlock(block.number);

        return newTotalSupply;
    }

    function payBorrow(uint256 amount) public {
        uint256 paid;
        uint256 additional;
        
        (paid, additional) = payBorrowInternal(msg.sender, msg.sender, amount);
        
        emit PayBorrow(msg.sender, paid);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }

    function payBorrowInternal(address payer, address borrower, uint256 amount) internal returns (uint256 paid, uint256 supplied) {
        accrueInterest();

        BorrowSnapshot storage snapshot = borrows[borrower];

        require(snapshot.principal > 0);

        uint256 interest = snapshot.principal.mul(borrowIndex).div(snapshot.interestIndex).sub(snapshot.principal);

        snapshot.principal = snapshot.principal.add(interest);
        snapshot.interestIndex = borrowIndex;

        uint256 additional;

        if (snapshot.principal < amount) {
            additional = amount.sub(snapshot.principal);
            amount = snapshot.principal;
        }

        require(token.transferFrom(payer, address(this), amount), "No enough tokens");
        if(snapshot.principal >amount){
            snapshot.principal = snapshot.principal.sub(amount);
        } else{
            snapshot.principal = 0;
        }
        if(totalBorrows>amount){
            totalBorrows = totalBorrows.sub(amount);
        } else{
            totalBorrows = 0;
        }

        // if (additional > 0)
        //     supplyInternal(payer, additional);
            
        return (amount, additional);
    }
    
    function liquidateBorrow(address borrower, uint256 amount, MarketInterface collateralMarket) public {
        require(amount > 0,'金额错误');
        require(borrower != msg.sender,'sender 错误');
        
        accrueInterest();
        collateralMarket.accrueInterest();

        uint256 debt = updatedBorrowBy(borrower);
        
        require(debt >= amount);
        require(token.balanceOf(msg.sender) >= amount);
        
        uint256 collateralAmount = controller.liquidateCollateral(borrower, msg.sender, amount, collateralMarket);

        uint256 paid;
        uint256 additional;

        (paid, additional) = payBorrowInternal(msg.sender, borrower, amount);
        
        emit LiquidateBorrow(borrower, paid, msg.sender, address(collateralMarket), collateralAmount);
        
        if (additional > 0)
            emit Supply(msg.sender, additional);
    }
    
    function transferTo(address sender, address receiver, uint256 amount) public onlyController {
        require(amount > 0);
        redeemInternal(sender, receiver, amount);
    }
}

