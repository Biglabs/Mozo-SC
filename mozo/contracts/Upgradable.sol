pragma solidity 0.4.23;
/**
 * @title Utility smart contracts
 * @author Biglabs Pte. Ltd.
 * @dev Upgradable contract with agent
 */
 
contract Upgradable {
    function upgrade() public;
    function getRequiredTokens(uint _level) public pure returns (uint);
    function getLevel() public view returns (uint);
}
