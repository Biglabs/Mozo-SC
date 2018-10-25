pragma solidity ^0.4.24;

/**
 * @title Using address ultility smart contract
 * @author Biglabs Pte. Ltd.
 */

contract CheckingAddress {
    mapping(address => bool) public addresses;
    
    constructor(address[] _addresses) internal {
        _addAddresses(_addresses);
    }

    function isAddress(address _address) public view returns(bool) {
        return addresses[_address];
    }

	/*
	 * @dev add list of addresses
	 * @param _addresses List of addresses
	*/
	function _addAddresses(address[] _addresses) internal {
        uint length = _addresses.length;
        for (uint i = 0; i < length; i++) {
            _addAddress(_addresses[i]);
        }
	}
	
	/*
	 * @dev add an address
	 * @param _address: address
	*/
	function _addAddress(address _address) internal {
	    addresses[_address] = true;
	}
	
	/*
	 * @dev disable list of addresses
	 * @param _addresses List of addresses
	*/
	function _disableAddresses(address[] _addresses) internal {
        uint length = _addresses.length;
        for (uint i = 0; i < length; i++) {
            _disableAddress(_addresses[i]);
        }
	}
	
	/*
	 * @dev add an address
	 * @param _address: address
	*/
	function _disableAddress(address _address) internal {
	    addresses[_address] = false;
	}
}