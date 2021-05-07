node invoke %1 %2 approve(address,uint256) %3;%4 fast
node invoke %1 %3 payBorrow(uint256) %4 fast

node invoke root token1 'approve(address,uint256)' 'market1;11000'

node invoke root market1 'payBorrow(uint256)' '110'