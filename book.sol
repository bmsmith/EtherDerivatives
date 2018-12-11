pragma solidity 0.4.24;
import "./exchange.sol";
import "./derivative.sol";

contract Book {
    mapping(uint => address) derivatives;
    uint derivative_id;
    constructor () public {
        derivative_id = 0;
    }
    function newcontract() public {
        address newderivative = new Derivative();
        derivatives[derivative_id] = newderivative;
        derivative_id++;
    }
    function getcontract(uint _derivative_id) public returns (address) {
        return derivatives[_derivative_id];
    }
}
