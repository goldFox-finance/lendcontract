#!/bin/sh
cd ..
truffle compile
cd commands
rm -rf build

# node deploy alice token1 FaucetToken "100000000000000000000000000;QS;18;QS"


# node deploy eth token2 CommonToken "1000000000000000000000000000000000;Token2-T;18;Token2-T"

# uniswap factory 0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f 
# usdt 0xa71edc38d189767582c38a3145b5873052c3e47a
# gfc 0xafe739209c8bd6993d0abdb50cab9bc4eafe68c4

# controller
node deploy alice controller Controller '0xb0b670fc1f7724119963018db0bfa86adb22d941;0xa71edc38d189767582c38a3145b5873052c3e47a'
node invoke alice controller 'setCollateralFactor(uint256)' 1000000
node invoke alice controller 'setLiquidationFactor(uint256)' 333300

# cru-martket
node deploy alice market1 Market '0x9aFE0DFB1D3E6767c127798fE5CDb18283cc4525;0xafe739209c8bd6993d0abdb50cab9bc4eafe68c4;30;1000000000;100000000000;25000;alice'
node invoke alice controller 'addMarket(address)' market1 
node invoke alice market1 'setController(address)' controller 
node invoke alice controller 'setPrice(address,uint256)' 'market1;10000000'

node deploy alice market4 Market '0xa71edc38d189767582c38a3145b5873052c3e47a;0xafe739209c8bd6993d0abdb50cab9bc4eafe68c4;30;1000000000;100000000000;25000;alice'
node invoke alice controller 'addMarket(address)' market4
node invoke alice market4 'setController(address)' controller 
node invoke alice controller 'setPrice(address,uint256)' 'market4;1000000'

node invoke alice token1 'approve(address,uint256)' 'market1;1000000000000000000000000000'

node invoke eth1 token2 'approve(address,uint256)' 'market4;10000000000000000000000000000'

echo " 存 0.01个cru"
node invoke alice market1 'supply(uint256)' '10000000000000000'
echo " 存 0.01个usdt"
node invoke eth1 market4 'supply(uint256)' '10000000000000000'
echo " 借 0.001个cru"
node invoke eth1 market1 'borrow(uint256)' '1000000000000'

node call eth1 controller 'getAccountLiquidity(address)' 'eth1'

# 清算
node invoke eth1 token2 'approve(address,uint256)' 'market4;100000000000000000000'

node call eth1 controller 'getAccountValues(address)' 'eth1'
echo " 进线清算 "
node invoke alice market1 'liquidateBorrow(address,uint256,address)' 'eth1;1000000000000;market4'
# node invoke alice market1 'liquidateBorrow()'

node invoke alice market1 'liquidateBorrow(address,uint256,address)' '0xA8eAF481e5412B5f5649840cB13f1Bf7bF98e0CA;3196055219737935;market4'

echo " 提现 0.01个usdt"
node invoke alice market1 'redeem(uint256)' '10000000000000000' 
echo " 提现 0.01个usdt"
node invoke eth1 market4 'redeem(uint256)' '10000000000000000' 

# node invoke eth token1 'addMiner(address)' 'market1'
# node invoke eth token1 'addMiner(address)' 'eth'
# node call eth token1 'balanceOf(address)' 'eth'

# 存钱
# node invoke eth token2 'approve(address,uint256)' 'market1;10000000000000000000000000000000' 
# node invoke eth market1 'supply(uint256)' '1000000000000000000' 
# node invoke eth market1 'updateSupplyPool()' 

# node call eth market1 'updatedSupplyOf(address)' 'eth' 
# node call eth token2 'balanceOf(address)' 'market1'
# node invoke eth market1 'redeem(uint256)' '1000000000000000000' 
# node call eth token1 'balanceOf(address)' 'eth'

# 借钱
# node invoke eth market1 'borrow(uint256)' '1000000000000000000'



# node invoke eth token1 'approve(address,uint256)' 'market1;10000000000000000000000000000000' 
# node invoke bob token1 'approve(address,uint256)' 'market1;10000000000000000000000000000000' 

# node invoke eth market1 'supply(uint256)' '1000000000000000000000' 

# node invoke bob market1 'supply(uint256)' '100000000000000000000' 

# node invoke bob market1 'borrow(uint256)' '50000000000000000000' 
# sleep 5

# node invoke bob market1 'payBorrow(uint256)' '50100025909090910000' 
# node call eth market1 'updatedSupplyOf(address)' 'eth'
# node invoke eth market1 'redeem(uint256)' '16000'

# fil-martket
# node deploy eth market2 Market 'token2;0xafe739209c8bd6993d0abdb50cab9bc4eafe68c4;1;1000000000;100000000000;30000;eth'
# node invoke eth controller 'addMarket(address)' market2 
# node invoke eth market2 'setController(address)' controller 
# node invoke eth controller 'setPrice(address,uint256)' 'market2;2'


# gfc-martket
# node deploy eth market3 Market '0xafe739209c8bd6993d0abdb50cab9bc4eafe68c4;0xafe739209c8bd6993d0abdb50cab9bc4eafe68c4;1;1000000000;100000000000;30000;eth'
# node invoke eth controller 'addMarket(address)' market3
# node invoke eth market3 'setController(address)' controller 
# node invoke eth controller 'setPrice(address,uint256)' 'market3;3'

# node call eth controller 'getInternalPrice(address)' '0xafe739209c8bd6993d0abdb50cab9bc4eafe68c4'

# node call eth market1 'getLendGfc(uint256)' '1000000000000000000000'


## USDT


# node invoke alice market1 '' '100000232500000000'

## USDT-TESTNET
# node deploy eth1 market3 Market '0x516de3a7a567d81737e3a46ec4ff9cfd1fcb0136;0xb0b670fc1f7724119963018db0bfa86adb22d941;10;1000000000;100000000000;25000;eth1'
# node invoke eth1 controller1 'addMarket(address)' market3
# node invoke eth1 market3 'setController(address)' controller1
# node invoke eth1 controller1 'setPrice(address,uint256)' 'market3;1000000'


# node deploy eth market3 Market 'token2;1000000000;100000000000;1000000000'
# node invoke eth controller 'addMarket(address)' market3 fast
# node invoke eth market3 'setController(address)' controller fast
# node invoke eth controller 'setPrice(address,uint256)' 'market3;10' fast

# node call eth controller 'getPrice(address)' 'market4'

# node call eth market1 'utilizationRateFraction()'


# node call eth market2 'borrowRatePerBlock()'

# node invoke eth market1 'setFutou(uint256)' '0x7722F81C8Fe8947894c6A625446bA1E8614E0AA0'

# node invoke eth market1 'setUtilizationRateFraction(uint256)' '100000000000' 

# node call eth market1 'balanceOf(address)' 'eth' 





# node invoke eth token2 'approve(address,uint256)' 'market1;10000000000000000000000000000000' 
# node call eth token1 'balanceOf(address)' 'eth' 
# node invoke eth market1 'supply(uint256)' '1000000000000000000' 

# node invoke eth market2 'redeem(uint256)' '11926611' 

# node call eth market3 'token()' 'market3'

# node call bob market1 'updatedSupplyOf(address)' 'bob'
# node call bob market1 'updatedBorrowBy(address)' 'bob'
# node call eth token2 'balanceOf(address)' 'market2' 

# node call eth controller 'getAccountValues(address)' 'eth'

# node invoke eth market1 'redeem(uint256)' '1' 


# node call eth controller 'getAccountValues(address)' 'eth'
# node call eth controller 'MANTISSA()' 'eth'
# node call eth controller 'collateralFactor()' 'eth'