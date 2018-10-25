pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./OwnerStandardERC20.sol";
import "./ERC20Exchangable.sol";
import "./Operationable.sol";

/**
 * @title Operation holder utility smart contract
 * @author Biglabs Pte. Ltd.
 * @dev Operation wallets
 */
 
contract OperationHolder is Operationable {
    Operationable internal operation;
    
    constructor(Operationable _operation) internal {
        operation = _operation;
    }
    
	/**
     * @dev Only owner
    */
    modifier onlyOwner() {
        require(msg.sender == operation.getOwner());
        _;
    }

	/**
     * @dev Only operation wallet
    */
    modifier onlyOperation() {
        require(operation.isOperationWallet(msg.sender));
        _;
    }

	/**
     * @dev Only ERC20 tokens smart contract
    */
    modifier onlyERC20() {
        require(msg.sender == address(getERC20()));
        _;
    }

    /**
     * @dev Get ERC20 tokens
     */
	function getERC20() public view returns(OwnerStandardERC20) {
	    return operation.getERC20();
	}

    /**
     * @dev Get owner
     */
	function getOwner() public view returns(address) {
	    return operation.getOwner();
	}

	/*
	 * @dev check whether is operation wallet
	*/
	function isOperationWallet(address _wallet) public view returns(bool) {
	    return operation.isOperationWallet(_wallet);
	}

    /**
     * @dev Get operation smart contract 
    */
    function getOperation() public view returns(Operationable) {
        return operation;
    }
}