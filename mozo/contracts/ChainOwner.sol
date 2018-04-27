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
        require(msg.sender == parent.owner());
        _;
    }

    function owner() public view returns (address) {
        return parent.owner();
    }

    modifier validOwner(OwnerERC20 _smzoToken) {
        //if this contract create manually then msg.sender == _smzoToken.owner
        if (msg.sender != _smzoToken.owner()) {
            //require this called from smart contract
            OwnerERC20 ico = OwnerERC20(msg.sender);
            //this will throw exception if not

            //ensure the same owner
            require(ico.owner() == _smzoToken.owner());
        }
        _;
    }
}
