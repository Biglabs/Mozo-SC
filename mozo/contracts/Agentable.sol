pragma solidity 0.4.23;

import "../../open-zeppelin/contracts/math/SafeMath.sol";

/**
 * @title Utility smart contracts
 * @author Biglabs Pte. Ltd.
 * @dev Sale smart contract with agent
 */
 
contract Agentable {
    //address of agency for receiving bonus
    address public agency;
    
        //make sure not a smart contract
    modifier onlyWalletAddress(address addr){
        require(addr != address(0x0));

        uint size;
        assembly { size := extcodesize(addr) }
        require(size == 0);
        _;
    }

    modifier onlyAgency() {
        require(msg.sender == agency);
        _;
    }

    modifier notAgency() {
        require(msg.sender != agency);
        _;
    }
    
    function Agentable(address _agency) internal onlyWalletAddress(_agency) {
        agency = _agency;
    }
}