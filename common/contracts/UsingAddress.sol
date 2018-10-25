pragma solidity ^0.4.24;

/**
 * @title Using address ultility smart contract
 * @author Biglabs Pte. Ltd.
 */

contract UsingAddress {
    mapping(address => bool) internal addresses;
    
    modifier checkAddressUsed(address _address) {
        require(!addresses[_address]);
        _;
        addresses[_address] = true;
    }
    
    function isAddressUsing(address _address) public view returns(bool) {
        return addresses[_address];
    }
}