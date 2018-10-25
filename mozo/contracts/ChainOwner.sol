pragma solidity ^0.4.24;

import "./OwnerERC20.sol";
import "./Owner.sol";

/**
 * @title Utility smart contracts
 * @author Biglabs Pte. Ltd.
 * @dev Chain smart contract with the same owner
 */
 
contract ChainOwner is Owner {
    //parent contract
    OwnerERC20 internal parent;

    /**
    * @param _parent The parent smart contract
    */
    constructor(OwnerERC20 _parent) internal {
        require(_parent.isValidOwner(msg.sender));
        parent = _parent;
    }

    modifier onlyOwner() {
        require(parent.isValidOwner(msg.sender));
        _;
    }

    function owner() public view returns (address) {
        return parent.owner();
    }

    function isValidOwner(address _address) public view returns(bool) {
        if (_address == owner()) {
            return true;
        }
        return false;
    }

}
