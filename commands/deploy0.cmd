node genaccount alice
node genaccount bob
node genaccount charlie

node transfer root alice 1000000000000
node transfer root bob 1000000000000
node transfer root charlie 1000000000000

node deploy alice token1 FaucetToken "1000000000000000000000000000000000;Token 1;18;CURT"
node deploy alice token2 FaucetToken "1000000000000000000000000000000000;Token 2;18;FILT"
node deploy alice token3 FaucetToken "100000000000;Token 3;18;TOK3"

node invoke alice token1 'allocateTo(address,uint256)' '"alice";1000000000000000000000000000000000'
node invoke alice token2 'allocateTo(address,uint256)' '"alice";1000000000000000000000000000000000'
node invoke root token3 'allocateTo(address,uint256)' 'charlie;1000000'

