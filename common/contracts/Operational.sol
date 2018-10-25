pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./OwnerStandardERC20.sol";
import "./ERC20Exchangable.sol";
import "./Operationable.sol";
import "./CheckingAddress.sol";

/**
 * @title Operation wallets utility smart contract
 * @author Biglabs Pte. Ltd.
 * @dev Operation wallets
 */
 
contract Operational is CheckingAddress, Operationable {

    //owner address
    address internal owner;
    
    //ERC20 token smart contract
    OwnerStandardERC20 internal standardToken;

	/**
     * @dev Only owner
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
	/**
     * @dev Only operation wallets or ERC20 tokens smart contract
    */
    modifier onlyOperationOrERC20() {
        require(msg.sender == address(standardToken) || isOperationWallet(msg.sender));
        _;
    }

	/**
     * @dev Only ERC20 tokens smart contract
    */
    modifier onlyERC20() {
        require(msg.sender == address(standardToken));
        _;
    }

	/**
     * @dev Only operation wallet
    */
    modifier onlyOperation() {
        require(isOperationWallet(msg.sender));
        _;
    }
	
    /**
     * @dev Operation wallets constructor
     * @param _operationWallets List of operation wallets
    */
    constructor(OwnerStandardERC20 _erc20, address[] _operationWallets) public CheckingAddress(_operationWallets){
	    //require the same owner of Mozo token smart contract
	    require(_erc20.owner() == msg.sender);
	    owner = msg.sender;
	    standardToken = OwnerStandardERC20(address(_erc20));
    }
    
    function addOperationWallets(address[] _wallets) public onlyOwner {
        _addAddresses(_wallets);
    }

    function addOperationWallet(address _wallet) public onlyOwner {
        _addAddress(_wallet);
    }
    
    

    function disableOperationWallet(address[] _wallets) public onlyOwner {
        _disableAddresses(_wallets);
    }

    function disableOperationWallet(address _wallet) public onlyOwner {
        _disableAddress(_wallet);
    }

	/*
	 * @dev check whether is operation wallet
	*/
	function isOperationWallet(address _wallet) public view returns(bool){
	    return isAddress(_wallet);
	}
	
    /**
     * @dev Get ERC20 tokens
     */
	function getERC20() public view returns(OwnerStandardERC20) {
	    return standardToken;
	}
	
    /**
     * @dev Get owner
     */
	function getOwner() public view returns(address) {
		return owner;
	}
}