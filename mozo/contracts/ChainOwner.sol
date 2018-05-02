pragma solidity 0.4.23;

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
    function ChainOwner(OwnerERC20 _parent) internal {
        parent = _parent;
    }

    modifier onlyOwner() {
        require(parent.isValidOwner(msg.sender));
        _;
    }

    function owner() public view returns (address) {
        return parent.owner();
    }

    modifier validOwner(OwnerERC20 _smzoToken) {
        //check if function not called by owner or coOwner
        if (!parent.isValidOwner(msg.sender)) {
            //require this called from smart contract
            OwnerERC20 ico = OwnerERC20(msg.sender);
            //this will throw exception if not

            //ensure the same owner
            require(ico.owner() == _smzoToken.owner());
        }
        _;
    }
    
    function isValidOwner(address _address) public view returns(bool) {
        if (_address == owner()) {
            return true;
        }
        return false;
    }

}
