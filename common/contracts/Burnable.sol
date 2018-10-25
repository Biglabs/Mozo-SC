pragma solidity ^0.4.24;

contract Burnable {
    //Burned event
    // _burner address of burner
    // _value Number of tokens
	event Burned(address indexed _burner, uint _value);
}