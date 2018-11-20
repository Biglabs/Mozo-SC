pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "../../common/contracts/OperationHolder.sol";
import "../../mozo/contracts/Timeline.sol";
/**
 * @title Airdrop for retailer tokens
 * @author Biglabs Pte. Ltd.
 */

contract Airdrop is Timeline, OperationHolder {
    using SafeMath for uint;
    
    //contract type
    string public constant contractType = "Airdrop";
    
    address public owner;

    //Retailer airdrop event
    // _operation Operational Wallet
    // _to Received address
    // _value Number of tokens
	event AirdropDone(address indexed _operation, address indexed _to, uint _value);

    //Number of tokens to be airdrop    
    uint public airdrop;

    //Number of requested retailer
    uint public requested;
    
    /**
     * @dev Airdrop for retailer constructor
     * @param _operation Operation smart contract
     * @param _airdrop Number of SOLO to airdrop for retailer
     * @param _startTime The opening time in seconds (unix Time)
     * @param _endTime The closing time in seconds (unix Time)
    */
    constructor(Operationable _operation, uint _airdrop, uint _startTime, uint _endTime) public Timeline(_startTime, _endTime) OperationHolder(_operation) {
        owner = msg.sender;
	    airdrop = _airdrop;
    }

    /**
     * @dev Get owner
     */
	function getOwner() public view returns(address) {
	    return owner;
	}
	
    /**
     * @dev Get number of Mozo ERC20 tokens in this smart contract
     */
	function noTokens() public view returns(uint) {
		return operation.getERC20().balanceOf(this);
	}
	
    /**
     * @dev Check whether airdrop is available
     */
	function isAvailable() public view returns(bool) {
		return ((noTokens() >= airdrop) && isOpened());
	}
    
    /**
     * @dev Get number of retailer can get airdrop
     */
	function noAirdrop() public view returns(uint) {
		return noTokens().div(airdrop);
	}
	
    /**
     * @dev Call by Bridge to get airdrop
     * @param _to Address of receiver
     */
	function doAirdrop(address _to) public onlyOperation onlyWhileOpen returns(bool) {
	    _doAirdrop(_to);
	}
    
    /**
     * @dev With
     * draw all tokens in case swapping contracts
     */
    function _withdraw() private {
		operation.getERC20().transfer(owner, noTokens());
	}

    /**
     * @param _to Address of receiver
     */
	function _doAirdrop(address _to) internal returns(bool) {
	    if(operation.getERC20().transfer(_to, airdrop)) {
	        requested = requested + 1;
	        emit AirdropDone(msg.sender, _to, airdrop);
	        return true;
	    }
	    return false;
	}

    /**
     * @dev Terminates the contract.
    */
    function destroy() public onlyOwner isEnded {
        _withdraw();
        selfdestruct(owner);
    }
}
