# 市场审查 清算逻辑

:loop

node invoke root mmr 'calculate()'

timeout /T 300

goto loop


node invoke root market1 'liquidateBorrow(address borrower, uint amount, MarketInterface collateralMarket)' 'root;100;market1'