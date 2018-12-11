pragma solidity 0.4.24;


contract exchange {
    uint order_index;
    uint asset_index;
    
    
    struct Asset {
        uint id;
        string symbol;
        uint price;
        bool onchain;
    }
    struct Order {
        uint id;
        uint asset_id;
        uint price;
        uint amount;
        uint block;
    }
    mapping(uint => Asset) private assets;
    mapping(uint => Order) private orderbook;
    constructor () public {
        order_index = 0;
        asset_index = 0;
    }
    function addOrder(uint _asset_id, uint _price, uint _amount) public {
        Order memory order = Order(order_index, _asset_id, _price, _amount, block.number);
        orderbook[order_index] = order;
        order_index++;
    }
    function addAsset(string _symbol, bool _onchain) public {
        Asset memory asset = Asset(asset_index, _symbol, 0, _onchain);
        assets[asset_index] = asset;
        asset_index++;
    }
    function updateAssetPrice(uint _asset_id, uint _price) public {
        Asset storage asset = assets[_asset_id];
        require(!asset.onchain, "Not an off-chain asset");
        asset.price = _price;
    }
    function getAssetPrice(uint _asset_id) public returns (uint) {
        Asset storage asset = assets[_asset_id];
        
        if (asset.onchain) {
            uint startblock = block.number - 6000;
            uint index = order_index - 1;
            bool cont = true;
            uint total_price = 0;
            uint total_amount = 0;
            while (cont && index >= 0) {
                Order storage currentorder = orderbook[index];
                
                if (currentorder.asset_id == _asset_id) {
                    total_price += currentorder.price * currentorder.amount;
                    total_amount += currentorder.amount;
                }
                index--;
                cont = (currentorder.block > startblock);
            }
            return total_price / total_amount;
        } else {
            return asset.price;
        }
    }
}
