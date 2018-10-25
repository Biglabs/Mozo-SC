pragma solidity ^0.4.24;

contract Mintable {
    /**
     * @dev Get owner
     */
	function mint(uint _value) public;
	
    //Mint event
    // _minter address of minter
    // _value Number of tokens
	event Mint(address indexed _minter, uint _value);
}