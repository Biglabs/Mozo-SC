pragma solidity 0.4.23;

import "./OwnerERC20.sol";
import "./ChainOwner.sol";

/**
 * @title Utility smart contracts
 * @author Biglabs Pte. Ltd.
 * @dev Chain smart contract with the same owner
 */
 
contract ChainCoOwner is ChainOwner {

    mapping(address=>bool) internal coOwner;

    /**
     * @param _parent The parent smart contract
     * @param _coOwner Array of coOwner
    */
    function ChainCoOwner(OwnerERC20 _parent, address[] _coOwner) ChainOwner(_parent) internal {
        uint len = _coOwner.length;
        for (uint i=0; i < len; i++) {
            coOwner[_coOwner[i]] = true;
        }
    }

    /**
     * @dev Check address is valid owner (owner or coOwner)
     * @param _address Address to check
     * 
    */
    function isValidOwner(address _address) public view returns(bool) {
        if (_address == owner() || coOwner[_address] == true) {
            return true;
        }
        return false;
    }

}
