pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "../../common/contracts/BasicTreasury.sol";
import "../../common/contracts/Mintable.sol";

/**
 * @title Treasury smart contract
 * @author Biglabs Pte. Ltd.
 * @dev : Treasury smart contract - use for Buy/Sell SOLO tokens
 */
 
contract SOLOTreasury is BasicTreasury {
    //contract type
    string public constant contractType = "Treasury";
    
    /**
     * @dev Treasury constructor
     * @param _operation Operation smart contract
     * @param _fixedFee How to calculate fee: true if fixed, else is percentage
     * @param _fee Fee (% if _fixedFee=false, else number of tokens)
     * @param _feeCollector wallet for collect fee
    */
    constructor(Operationable _operation, bool _fixedFee, uint _fee, address _feeCollector) public BasicTreasury(_operation) {
        setFeeModel(_fixedFee, _fee);
        setFeeCollector(_feeCollector);
    }
    
    /**
     * @dev called by Bridge when a bought event occurs, it will transfer ERC20 tokens to receiver address
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
     */
    function sold(bytes32 _hash, address _from, address _to, uint _value) public onlyOperation returns(bool) {
        Mintable minter = Mintable(address(operation.getERC20()));
        minter.mint(_value);
        return BasicTreasury.sold(_hash, _from, _to, _value);
    }
}