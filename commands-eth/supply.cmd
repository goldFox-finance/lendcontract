# node invoke %1 %2 approve(address,uint256) %3;%4 fast
# node invoke %1 %3 supply(uint256) %4 fast


node invoke root token1 'approve(address,uint256)' 'market1;9999999999999999999999999999999999999999999999999999' fast

node invoke root market1 'supply(uint256)' 999 fast



node invoke bob token2 'approve(address,uint256)' 'market2;9999999999999999999999999999999999999999999999999999' fast

node invoke bob market2 'supply(uint256)' 1000 fast