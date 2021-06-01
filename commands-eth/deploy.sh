#!/bin/sh
cd ..
truffle compile
cd commands

# node deploy eth token1 FaucetToken "100000000000000000000000000;CRU;18;CRU"


# node deploy eth token2 CommonToken "1000000000000000000000000000000000;Token2-T;18;Token2-T"

# uniswap factory 0x1f98431c8ad98523631ae4a59f267346ea31f984 
# usdt 0xc2118d4d90b274016cb7a54c03ef52e6c537d957
# gfc 0x880BC7EF52aC04181B156BC25F8E4Dd2aF84dD95

# controller
node deploy eth controller Controller '0x1f98431c8ad98523631ae4a59f267346ea31f984;0xc2118d4d90b274016cb7a54c03ef52e6c537d957'
node invoke eth controller 'setCollateralFactor(uint256)' 1000000
node invoke eth controller 'setLiquidationFactor(uint256)' 500000

# cru-martket
node deploy eth market1 Market '0xFC9AebDdC8d16b3D7034A7555215c61a613d2a63;0x880BC7EF52aC04181B156BC25F8E4Dd2aF84dD95;1;1000000000;100000000000;50000;eth'
node invoke eth controller 'addMarket(address)' market1 
node invoke eth market1 'setController(address)' controller 
node invoke eth controller 'setPrice(address,uint256)' 'market1;1'
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
# node deploy eth market2 Market 'token2;0x880BC7EF52aC04181B156BC25F8E4Dd2aF84dD95;1;1000000000;100000000000;30000;eth'
# node invoke eth controller 'addMarket(address)' market2 
# node invoke eth market2 'setController(address)' controller 
# node invoke eth controller 'setPrice(address,uint256)' 'market2;2'


# gfc-martket
# node deploy eth market3 Market '0x880BC7EF52aC04181B156BC25F8E4Dd2aF84dD95;0x880BC7EF52aC04181B156BC25F8E4Dd2aF84dD95;1;1000000000;100000000000;30000;eth'
# node invoke eth controller 'addMarket(address)' market3
# node invoke eth market3 'setController(address)' controller 
# node invoke eth controller 'setPrice(address,uint256)' 'market3;3'

# node call eth controller 'getInternalPrice(address)' '0x880BC7EF52aC04181B156BC25F8E4Dd2aF84dD95'

# node call eth market1 'getLendGfc(uint256)' '1000000000000000000000'


## USDT
node deploy eth market4 Market '0xc2118d4d90b274016cb7a54c03ef52e6c537d957;0x880BC7EF52aC04181B156BC25F8E4Dd2aF84dD95;1;1000000000;100000000000;30000;eth'
node invoke eth controller 'addMarket(address)' market4
node invoke eth market4 'setController(address)' controller 
node invoke eth controller 'setPrice(address,uint256)' 'market4;1'


# node deploy eth market3 Market 'token2;1000000000;100000000000;1000000000'
# node invoke eth controller 'addMarket(address)' market3 fast
# node invoke eth market3 'setController(address)' controller fast
# node invoke eth controller 'setPrice(address,uint256)' 'market3;10' fast

# node call eth controller 'getPrice(address)' 'market4'

# node call eth market1 'utilizationRateFraction()'


# node call eth market2 'borrowRatePerBlock()'

# node invoke eth market1 'setFutou(uint256)' '0x7722F81C8Fe8947894c6A625446bA1E8614E0AA0'

# node invoke eth market1 'setUtilizationRateFraction(uint256)' '300000000000' 

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