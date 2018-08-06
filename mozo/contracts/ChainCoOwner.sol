
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
    
    address[] internal coOwnerList;

    /**
     * @param _parent The parent smart contract
     * @param _coOwner Array of coOwner
    */
    constructor(OwnerERC20 _parent, address[] _coOwner) ChainOwner(_parent) internal {
        _addCoOwners(_coOwner);
    }
    
    function _addCoOwners(address[] _coOwner) internal {
        uint len = _coOwner.length;
        for (uint i=0; i < len; i++) {
            _addCoOwner(_coOwner[i]);
        }
    }

    function _addCoOwner(address _coOwner) internal {
        coOwner[_coOwner] = true;
        coOwnerList.push(_coOwner);
    }

    function _disableCoOwner(address _coOwner) internal {
        coOwner[_coOwner] = false;
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
