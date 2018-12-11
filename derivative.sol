pragma solidity 0.4.24;
import "./exchange.sol";
contract Derivative {
    
    enum ContractStatus {Pending, Open, MarginCall, Closed, Finalized}
    Exchange exchange;
    address long;
    address short;
    uint asset_id;
    uint principal;
    uint principal_eth;
    uint margin_req;
    uint margin;
    uint margincalltime;
    uint margincallamt;
    ContractStatus state;
    uint contractEndTime;
    function open(uint _asset_id,
                  uint _margin_req,
                  uint _contractEndTime,
                  address _exchange) public payable {
                asset_id = _asset_id;
                principal = msg.value / exchange.getAssetPrice(asset_id);
                principal_eth = msg.value;
                margin_req = _margin_req;
                state = ContractStatus.Pending;
                contractEndTime = _contractEndTime;
                long = msg.sender;
                exchange = Exchange(_exchange);
            

    }
    function matchmargin() public payable {
        require(state == ContractStatus.Pending);
        short = msg.sender;
        margin = msg.value;
        state = ContractStatus.Open;
    }
    function close() public {
        require((state == ContractStatus.MarginCall && now > 86400000 + margincalltime) || (state == ContractStatus.Open && now > contractEndTime));
        state = ContractStatus.Closed;
    }
    function callmargin() public {
        require(msg.sender == long);
        
        require(state == ContractStatus.Open);
        uint requiredmargin = (exchange.getAssetPrice(asset_id) * principal * margin_req) - margin;
        require(requiredmargin > 0);
        margincallamt = requiredmargin;
        margincalltime = now;
        state = ContractStatus.MarginCall;
    }
    function postmargin() public payable {
        require(state == ContractStatus.MarginCall);
        require(msg.sender == short);
        margin += msg.value;
        if(margincallamt <= msg.value) {
            state = ContractStatus.Open;
        }
    }
    function withdraw_long() public {
        require(msg.sender == long);
        require(state == ContractStatus.Closed);
        require(principal > 0);
        uint finalPrincipalEth = principal * exchange.getAssetPrice(asset_id);
        msg.sender.transfer(finalPrincipalEth);
        principal = 0;
        if(margin == 0) {
            state = ContractStatus.Finalized;
        }
        
    }
    function withdraw_short() public {
        require(msg.sender == short);
        require(state == ContractStatus.Closed);
        require(margin > 0);
        msg.sender.transfer(principal_eth + margin - (principal * exchange.getAssetPrice(asset_id)));
        if(principal == 0) {
            state = ContractStatus.Finalized;
        }
    }
}
