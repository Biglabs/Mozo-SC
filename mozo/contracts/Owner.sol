pragma solidity 0.4.23;

/**
 * @title Utility interfaces
 * @author Biglabs Pte. Ltd.
 * @dev Smart contract with owner
*/

contract Owner {
    /**
    * @dev Get smart contract's owner
    * @return The owner of the smart contract
    */
    function owner() public view returns (address);
}
