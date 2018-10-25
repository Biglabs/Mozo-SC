pragma solidity ^0.4.24;

import "./OwnerStandardERC20.sol";
import "./Operationable.sol";

contract ERC20Exchangable is Operationable{
    //Buy event
    // _from Bought address
    // _to Received address
    // _value Number of tokens
	event Buy(address indexed _from, address indexed _to, uint _value);

    //Sold event
    // _operation Operational Wallet
    // _hash Previous transaction hash of initial blockchain
    // _from Bought address
    // _to Received address
    // _value Number of tokens
    // _fee Fee
	event Sold(address indexed _operation, bytes32 _hash, address indexed _from, address indexed _to, uint _value, uint _fee);
	
    /**
     * @notice This method called by ERC20 smart contract
     * @dev Buy ERC20 tokens in other blockchain
     * @param _from Bought address
     * @param _to The address in other blockchain to transfer tokens to.
     * @param _value Number of tokens
     */
	function autoBuyERC20(address _from, address _to, uint _value) public;
    
    /**
     * @dev called by Bridge or operational wallet (multisig or none) when a bought event occurs,it will transfer ERC20 tokens to receiver address
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
     */
    function sold(bytes32 _hash, address _from, address _to, uint _value) public returns(bool);

    /**
     * @dev called by Bridge when a bought event occurs, it will transfer ERC20 tokens to receiver address
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
     */
    function soldWithFee(bytes32 _hash, address _from, address _to, uint _value) public returns(bool);
}