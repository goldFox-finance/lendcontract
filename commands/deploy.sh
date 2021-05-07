#!/bin/sh


# mdex factory 0xb0b670fc1f7724119963018db0bfa86adb22d941 
# usdt 0xa71edc38d189767582c38a3145b5873052c3e47a
# gfc 0xd9be10a6580db5675cedc420ae6c7c2888891132

# controller
# node deploy alice controller Controller '0xb0b670fc1f7724119963018db0bfa86adb22d941;0xa71edc38d189767582c38a3145b5873052c3e47a'
# node invoke alice controller 'setCollateralFactor(uint256)' 1000000
# node invoke alice controller 'setLiquidationFactor(uint256)' 500000

# cru-martket
# node deploy alice market1 Market 'token1;0xd9be10a6580db5675cedc420ae6c7c2888891132;1;1000000000;100000000000;30000;alice'
# node invoke alice controller 'addMarket(address)' market1 
# node invoke alice market1 'setController(address)' controller 
# node invoke alice controller 'setPrice(address,uint256)' 'market1;1'

# node invoke alice token1 'approve(address,uint256)' 'market1;10000000000000000000000000000000' 
# node invoke bob token1 'approve(address,uint256)' 'market1;10000000000000000000000000000000' 

# node invoke alice market1 'supply(uint256)' '1000000000000000000000' 

# node invoke bob market1 'supply(uint256)' '100000000000000000000' 

# node invoke bob market1 'borrow(uint256)' '50000000000000000000' 
# sleep 5

# node invoke bob market1 'payBorrow(uint256)' '50100025909090910000' 
# node call alice market1 'updatedSupplyOf(address)' 'alice'
# node invoke alice market1 'redeem(uint256)' '16000'

# fil-martket
node deploy alice market2 Market 'token2;0xd9be10a6580db5675cedc420ae6c7c2888891132;1;1000000000;100000000000;30000;alice'
node invoke alice controller 'addMarket(address)' market2 
node invoke alice market2 'setController(address)' controller 
node invoke alice controller 'setPrice(address,uint256)' 'market2;2'


# gfc-martket
# node deploy alice market3 Market '0xD9be10A6580db5675cEdC420AE6c7C2888891132;0xd9be10a6580db5675cedc420ae6c7c2888891132;1;1000000000;100000000000;30000;alice'
# node invoke alice controller 'addMarket(address)' market3
# node invoke alice market3 'setController(address)' controller 
# node invoke alice controller 'setPrice(address,uint256)' 'market3;3'

# node call alice controller 'getInternalPrice(address)' '0xd9be10a6580db5675cedc420ae6c7c2888891132'

# node call alice market1 'getLendGfc(uint256)' '1000000000000000000000'


## USDT
node deploy alice market4 Market '0xa71edc38d189767582c38a3145b5873052c3e47a;0xd9be10a6580db5675cedc420ae6c7c2888891132;1;1000000000;100000000000;30000;alice'
node invoke alice controller 'addMarket(address)' market4
node invoke alice market4 'setController(address)' controller 
node invoke alice controller 'setPrice(address,uint256)' 'market4;1'


# node deploy alice market3 Market 'token2;1000000000;100000000000;1000000000'
# node invoke alice controller 'addMarket(address)' market3 fast
# node invoke alice market3 'setController(address)' controller fast
# node invoke alice controller 'setPrice(address,uint256)' 'market3;10' fast

# node call alice controller 'getPrice(address)' 'market4'

# node call alice market1 'utilizationRateFraction()'


# node call alice market2 'borrowRatePerBlock()'

# node invoke alice market1 'setFutou(uint256)' '0x7722F81C8Fe8947894c6A625446bA1E8614E0AA0'

# node invoke alice market1 'setUtilizationRateFraction(uint256)' '300000000000' 

# node call alice market1 'balanceOf(address)' 'alice' 





# node invoke alice token1 'approve(address,uint256)' 'market1;10000000000000000000000000000000' 
# node call alice token1 'balanceOf(address)' 'alice' 
# node invoke alice market1 'supply(uint256)' '1000000000000000000' 

# node invoke alice market2 'redeem(uint256)' '11926611' 

# node call alice market3 'token()' 'market3'

# node call bob market1 'updatedSupplyOf(address)' 'bob'
# node call bob market1 'updatedBorrowBy(address)' 'bob'
# node call alice token2 'balanceOf(address)' 'market2' 

# node call alice controller 'getAccountValues(address)' 'alice'

# node invoke alice market1 'redeem(uint256)' '1' 


# node call alice controller 'getAccountValues(address)' 'alice'
# node call alice controller 'MANTISSA()' 'alice'
# node call alice controller 'collateralFactor()' 'alice'