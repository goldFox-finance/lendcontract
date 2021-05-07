
const pages = (function () {
    let active = null;
    
    function goTo(page) {
        if (active) {
            $("#page_" + active).hide();
        
            const olditem = $("#item_" + active);
            
            if (olditem)
                olditem.removeClass('nav-active');
        }
        
        $("#page_" + page).show();
        
        active = page;
        
        const newitem = $("#item_" + active);
        
        if (newitem)
            newitem.addClass('nav-active');
    }
    
    return {
        goTo: goTo
    }
})();

const config = {
    "host": "http://127.0.0.1:7545",
    "accounts": {
        "root": "0x15C6A4b111Da3614B200fD4b15731f79012F7c3d",
        "alice": {
            "privateKey": "b26a71b3ab029a32fd42dd1641eabd6136466e9a586179c53ec2f8b57df58477",
            "publicKey": "",
            "address": "0x15C6A4b111Da3614B200fD4b15731f79012F7c3d"
        },
        "bob": {
            "privateKey": "b33a4c9e3f50f3cf9ec09c59a2e456d1c7d1cf2b269b3f233bc560c6db411702",
            "publicKey": "",
            "address": "0x6666567B3358A89C23caD4517A8748e3aaaBD061"
        },
        "charlie": {
            "privateKey": "b4b3039c22f53ca76e1d314b8588746f4fc57c0d2957b1314f8e8d1162620d3b",
            "publicKey": "",
            "address": "0xdd1Fd9108783A904692Ccf36748f36881811868b"
        }
    },
    "instances": {
        "token1": {
            "address": "0x7392a0a585b82b78bbde7fef9af62dcca37494c2",
            "contract": "FaucetToken"
        },
        "token2": {
            "address": "0x8c62c033d0ccad3c14e7220f4d29c46b1263be5b",
            "contract": "FaucetToken"
        },
        "token3": {
            "address": "0x070f01d5624900603b329068c115eebc5dcd7818",
            "contract": "FaucetToken"
        },
        "controller": {
            "address": "0x1602a57494b8722ee7a4caeb52fda864b324ef67",
            "contract": "Controller"
        },
        "market1": {
            "address": "0x603767f84b409ff18caf4d826fa2de8615f2375c",
            "contract": "Market"
        },
        "market2": {
            "address": "0xe77d281c218feb953ca158a5141d5aedbf0d4778",
            "contract": "Market"
        },
        "market3": {
            "address": "0x8e6cdbfc06b5f992bf104df1dd0cf32299854ba0",
            "contract": "Market"
        }
    },
    "options": {}
};

const rootaddress = config.accounts.root.address ? config.accounts.root.address : config.accounts.root;

const fnhashes = {
    'balanceOf(address)': '0x1d7976f3'
}

var app = (function () {
    var names = [ 'Alice', 'Bob', 'Charlie', 'David', 'Eve', 'Fiona', 'Ginger', 'Hanna', 'Ian', 'John', 'Kim', 'Louise', 'Marty', 'Nancy', 'Ophrah', 'Peter', 'Robert', 'Sam', 'Tina', 'Umma', 'Vanessa', 'Wilma' ];
    
    var id = 0;
    var mainhost;
    var sidehost;
    
    function post(host, request, fn) {
// https://stackoverflow.com/questions/2845459/jquery-how-to-make-post-use-contenttype-application-json
        
        $.ajaxSetup({
            contentType: "application/json; charset=utf-8"
        });
        
        $.post(
            host,
            JSON.stringify(request),
            fn
        );
    }

    function show(data) {
        alert(JSON.stringify(data, null, 4));
    }
        
    function fetchBalances(bfn) {
        for (let n in config.accounts)
            fetchAccountBalances(n, config.accounts[n]);
        
        function fetchAccountBalances(accountname, account) {
            fetchAccountBalance(accountname, account, 'rbtc');
            
            for (let n in config.instances)
                fetchAccountAssetBalance(accountname, account, n, config.instances[n]);
        }
         
        function fetchAccountBalance(accountname, account, assetname) {
            const address = account.address ? account.address : account;
            
            var request = {
                id: ++id,
                jsonrpc: "2.0",
                method: "eth_getBalance",
                params: [ address, 'latest']
            };
            
            post(config.host, request, function (data) {
                if (typeof data === 'string')
                    data = JSON.parse(data);
                
                const balance = parseInt(data.result);
                
                bfn(accountname, assetname, balance);
            });
        }
        
        function fetchAccountAssetBalance(accountname, account, assetname) {
            const address = account.address ? account.address : account;
            
            const request = {
                id: ++id,
                jsonrpc: "2.0",
                method: "eth_call",
                params: [ {
                    from: rootaddress,
                    to: config.instances[assetname].address,
                    gas: '0x010000',
                    gasPrice: '0x0',
                    value: '0x0',
                    data: '0x70a08231' + toHex(address)
                }, 'latest' ]
            };
            
            post(config.host, request, function (data) {
                if (typeof data === 'string')
                    data = JSON.parse(data);
                
                const balance = parseInt(data.result);
                
                bfn(accountname, assetname, balance);
            });
        }
    }
    
    function fetchPositions(bfn) {
        for (let n in config.accounts) {
            if (n === 'root')
                continue;
            
            fetchAccountPositions(n, config.accounts[n]);
        }
        
        function fetchAccountPositions(accountname, account) {
            for (let n in config.instances) {
                if (!n.startsWith('market'))
                    continue;
                
                fetchAccountMarketPositions(accountname, account, n, config.instances[n]);
            }
        }
         
        function fetchAccountMarketPositions(accountname, account, marketname, market) {
            const address = account.address ? account.address : account;
            
            const request = {
                id: ++id,
                jsonrpc: "2.0",
                method: "eth_call",
                params: [ {
                    from: rootaddress,
                    to: config.instances[marketname].address,
                    gas: '0x010000',
                    gasPrice: '0x0',
                    value: '0x0',
                    data: '0xe681dc71' + toHex(address)
                }, 'latest' ]
            };
                        
            post(config.host, request, function (data) {
                if (typeof data === 'string')
                    data = JSON.parse(data);
                
                const value = parseInt(data.result);
                
                bfn(accountname, marketname, 'supplies', value);
            });
            
            const request2 = {
                id: ++id,
                jsonrpc: "2.0",
                method: "eth_call",
                params: [ {
                    from: rootaddress,
                    to: config.instances[marketname].address,
                    gas: '0x010000',
                    gasPrice: '0x0',
                    value: '0x0',
                    data: '0x2aad6aa8' + toHex(address)
                }, 'latest' ]
            };
                        
            post(config.host, request2, function (data) {
                if (typeof data === 'string')
                    data = JSON.parse(data);
                
                const value = parseInt(data.result);
                
                bfn(accountname, marketname, 'borrows', value);
            });
        }
    }
    
    function fetchLiquidities(bfn) {
        for (let n in config.accounts) {
            if (n === 'root')
                continue;
            
            fetchAccountLiquidity(n, config.accounts[n]);
        }
        
        function fetchAccountLiquidity(accountname, account) {
            const address = account.address ? account.address : account;
            
            var request = {
                id: ++id,
                jsonrpc: "2.0",
                method: "eth_call",
                params: [ {
                    from: rootaddress,
                    to: config.instances.controller.address,
                    gas: '0x010000',
                    gasPrice: '0x0',
                    value: '0x0',
                    data: '0x5ec88c79' + toHex(account.address)
                }, 'latest' ]
            };
                        
            post(config.host, request, function (data) {
                if (typeof data === 'string')
                    data = JSON.parse(data);
                
                const liquidity = parseInt(data.result);
                
                bfn(accountname, liquidity);
            });
        }
    }

    function fetchMarkets(bfn) {
        for (let n in config.instances) {
            if (!n.startsWith('market'))
                continue;
            
            fetchMarket(n);
        }
        
        function fetchMarket(marketname) {
            const request = {
                id: ++id,
                jsonrpc: "2.0",
                method: "eth_call",
                params: [ {
                    from: rootaddress,
                    to: config.instances[marketname].address,
                    gas: '0x010000',
                    gasPrice: '0x0',
                    value: '0x0',
                    data: '0xc2b170cb'
                }, 'latest' ]
            };
                        
            post(config.host, request, function (data) {
                if (typeof data === 'string')
                    data = JSON.parse(data);
                
                const value = parseInt(data.result);
                
                bfn(marketname, 'supplies', value);
            });
            
            const request2 = {
                id: ++id,
                jsonrpc: "2.0",
                method: "eth_call",
                params: [ {
                    from: rootaddress,
                    to: config.instances[marketname].address,
                    gas: '0x010000',
                    gasPrice: '0x0',
                    value: '0x0',
                    data: '0x78f1dc03'
                }, 'latest' ]
            };
                        
            post(config.host, request2, function (data) {
                if (typeof data === 'string')
                    data = JSON.parse(data);
                
                const value = parseInt(data.result);
                
                bfn(marketname, 'borrows', value);
            });
        }
        
        function fetchAccountAssetBalance(accountname, account, assetname) {
            const address = account.address;
           
            const request = {
                id: ++id,
                jsonrpc: "2.0",
                method: "eth_call",
                params: [ {
                    from: rootaddress,
                    to: config.instances[assetname].address,
                    gas: '0x010000',
                    gasPrice: '0x0',
                    value: '0x0',
                    data: '0x70a08231' + toHex(account.address)
                }, 'latest' ]
            };
            
            post(config.host, request, function (data) {
                if (typeof data === 'string')
                    data = JSON.parse(data);
                
                const balance = parseInt(data.result);
                
                bfn(accountname, assetname, balance);
            });
        }
    }
    
    function randomAccount(accounts) {
        while (true) {            
            var n = Math.floor(Math.random() * accounts.length);
            
            if (accounts[n].name.indexOf('ridge') >= 0)
                continue;
            
            if (accounts[n].address.address)
                return accounts[n].address.address;
            
            return accounts[n].address;
        }
    }
    
    function toHex(value) {
        if (typeof value === 'string' && value.substring(0, 2) === '0x')
            var text = value.substring(2);
        else
            var text = value.toString(16);
        
        while (text.length < 64)
            text = '0' + text;
        
        return text;
    }
    
    function getNonce(host, address, fn) {
        var request = {
            id: ++id,
            jsonrpc: "2.0",
            method: "eth_getTransactionCount",
            params: [ address, "pending" ]
        };
        
        post(host, request, fn);
    }

// https://ethereum.stackexchange.com/questions/8579/how-to-use-ethereumjs-tx-js-in-a-browser

    function transferWithSignature(network, from, to, token, amount, nonce) {
        let privateKey = from.privateKey;
        
        if (privateKey.startsWith('0x'))
            privateKey = privateKey.substring(2);
        
        const privateBuffer = new ethereumjs.Buffer.Buffer(privateKey, 'hex');

        const toaddress = to.address ? to.address : to;
        
        var transaction = {
            nonce: nonce,
            to: token,
            value: 0,
            gas: 6000000,
            gasPrice: 0,
            data: "0xa9059cbb000000000000000000000000" + toaddress.substring(2) + toHex(amount)
        };
        
        const tx = new ethereumjs.Tx(transaction);
        tx.sign(privateBuffer);
        const serializedTx = tx.serialize().toString('hex'); 
        
        var request = {
            id: ++id,
            jsonrpc: "2.0",
            method: "eth_sendRawTransaction",
            params: [ serializedTx ]
        };
        
        post(getHost(network), request, console.log);
    }

    function transfer(network, from, to, token, amount) {
        if (from && from.privateKey) {
            getNonce(network, from.address, function (data) {
                if (typeof data === 'string')
                    data = JSON.parse(data);
                transferWithSignature(network, from, to, token, amount, data.result);
            });
            
            return;
        }

        var tx = {
            from: from,
            to: token,
            value: 0,
            gas: 6000000,
            gasPrice: 0,
            data: "0xa9059cbb000000000000000000000000" + to.substring(2) + toHex(amount)
        };
        
        var request = {
            id: ++id,
            jsonrpc: "2.0",
            method: "eth_sendTransaction",
            params: [ tx ]
        };
        
        post(getHost(network), request, console.log);
    }

    function distributeTokens(network, accounts, cb) {
        var naccounts = accounts.length;
        
        for (var k = 0; k < naccounts; k++) {
            var name = accounts[k].name;
            
            if (name.indexOf('ridge') >= 0)
                continue;
            
            if (accounts[k].balance)
                distributeToken(network, accounts[k].address, accounts[k].balance, getToken(network), accounts);
        }
        
        setTimeout(cb, 2000);
    }
    
    return {
        fetchBalances: fetchBalances,
        fetchLiquidities: fetchLiquidities,
        fetchMarkets: fetchMarkets,
        fetchPositions: fetchPositions
    }
})();

