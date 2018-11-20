pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./OwnerStandardERC20.sol";
import "./ERC20Exchangable.sol";
import "./OperationHolder.sol";
/**
 * @title Basic treasury smart contract
 * @author Biglabs Pte. Ltd.
 * @dev : Treasury smart contract - use for Buy/Sell tokens
 */
 
contract BasicTreasury is OperationHolder, ERC20Exchangable {
    using SafeMath for uint;
    
    address internal feeCollector;
    
    //How to calculate fee: true if fixed, else is percentage
    bool internal fixedFee;
    
    //Fee (% if fixedFee=false, else number of tokens)
    uint internal fee;
    
    uint public constant MAX_PERCENTAGE_FEE = 50;
    /**
     * @dev Basic Treasury constructor
     * @param _operation Address of operation smart contract
    */
    constructor(Operationable _operation) public OperationHolder(_operation) {
        require(operation.getERC20().owner() == msg.sender);
    }

    /**
     * @dev Set fee collector
     * @param _feeCollector wallet for collect fee
    */
    function setFeeCollector(address _feeCollector) public onlyOwner{
	    feeCollector = _feeCollector;
    }

    /**
     * @dev Get fee collector
    */
    function getFeeCollector() public view returns(address) {
	    return feeCollector;
    }

    /**
     * @dev Set fee
     * @param _fee Fee (% if _fixedFee=false, else number of tokens)
    */
    function setFee(uint _fee) public onlyOwner {
        if(!fixedFee) {
            require(_fee < MAX_PERCENTAGE_FEE);
        }
        fee = _fee;        
    }
    
    /**
     * @dev Get fee
     * @return % if _fixedFee=false, else number of tokens
    */
    function getFee() public view returns(uint) {
        return fee;
    }

    /**
     * @dev Check whether this is fixed fee
    */ 
    function isFixedFee() public view returns(bool){
        return fixedFee;
    }

    /**
     * @dev Set fee model
     * @param _fixedFee How to calculate fee: true if fixed, else is percentage
     * @param _fee Fee (% if _fixedFee=false, else number of tokens)
    */
    function setFeeModel(bool _fixedFee, uint _fee) public onlyOwner {
        if(!_fixedFee) {
            require(_fee < MAX_PERCENTAGE_FEE);
        }
        
        fixedFee = _fixedFee;
        fee = _fee;        
    }

    /**
     * @notice This method called by ERC20 smart contract
     * @dev Buy ERC20 tokens in other blockchain
     * @param _from Bought address
     * @param _to The address in other blockchain to transfer tokens to.
     * @param _value Number of tokens
     */
    function autoBuyERC20(address _from, address _to, uint _value) public onlyERC20 {
		emit Buy(_from, _to, _value);
    }

    /**
     * @dev called by Bridge when a bought event occurs, it will transfer ERC20 tokens to receiver address
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
     */
    function sold(bytes32 _hash, address _from, address _to, uint _value) public onlyOperation returns(bool) {
        if (operation.getERC20().transfer(_to, _value)) {
			emit Sold(msg.sender, _hash, _from, _to, _value, 0);
            return true;
        }
        return false;
    }
    
    /**
     * @dev get minimum tokens can be sold
     */
    function minimumTokens() public view returns(uint) {
        return calculateMinimumTokens(fixedFee, fee);
    }
    
    /**
     * @dev calculate minimum tokens can be sold
     * @param _fixedFee How to calculate fee: true if fixed, else is percentage
     * @param _fee Fee (% if _fixedFee=false, else number of tokens)
     */
    function calculateMinimumTokens(bool _fixedFee, uint _fee) public pure returns(uint) {
        if(_fixedFee) {
            return _fee;
        }
        if(_fee == 0) {
            return 0;
        }
        uint ret = uint(100).div(_fee);
        if( _fee.mul(ret) < 100) {
            return ret.add(1);
        }
        return ret;
    }
    
    /**
     * @dev called by Bridge when a bought event occurs, it will transfer ERC20 tokens to receiver address
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
     */
    function soldWithFee(bytes32 _hash, address _from, address _to, uint _value) public onlyOperation returns(bool) {
        require(_value >= minimumTokens());
        uint f = calculateFee(fixedFee, fee, _value);
        uint noTokens = _value - f;
        operation.getERC20().transfer(feeCollector, f);

        if (operation.getERC20().transfer(_to, noTokens)) {
			emit Sold(msg.sender, _hash, _from, _to, noTokens, f);
            return true;
        }
        return false;
    }

    /**
     * @dev Calculate fee
     * @param _fixedFee How to calculate fee: true if fixed, else is percentage
     * @param _fee Fee (% if _fixedFee=false, else number of tokens)
     * @param _value number of tokens
    */
    function calculateFee(bool _fixedFee, uint _fee, uint _value) public pure returns(uint) {
        if(_fixedFee) {
            return _fee;
        }
        if(_fee == 0) {
            return 0;
        }
        return _value.mul(_fee).div(100);
    }

    /**
     * @dev Get number of Mozo ERC20 tokens in this smart contract
     */
	function noTokens() public view returns(uint) {
		return operation.getERC20().totalSupply();
	}
	
    /**
     * @dev Withdraw all tokens in case swapping contracts
     */
    function _withdraw() private {
		operation.getERC20().transfer(getOwner(), noTokens());
	}

    /**
     * @dev Terminates the contract.
    */
    function destroy() public onlyOwner {
        _withdraw();
        selfdestruct(getOwner());
    }
}