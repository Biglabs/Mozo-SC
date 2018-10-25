pragma solidity ^0.4.24;

import "./OwnerStandardERC20.sol";

contract Operationable {
    /**
     * @dev Get owner
     */
	function getOwner() public view returns(address);
	
    /**
     * @dev Get ERC20 tokens
     */
	function getERC20() public view returns(OwnerStandardERC20);
	/*
	 * @dev check whether is operation wallet
	*/
	function isOperationWallet(address _wallet) public view returns(bool);
}