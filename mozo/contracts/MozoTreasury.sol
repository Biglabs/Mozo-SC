pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "../../common/contracts/BasicTreasury.sol";

/**
 * @title Treasury smart contract
 * @author Biglabs Pte. Ltd.
 * @dev : Treasury smart contract - use for Buy/Sell SOLO tokens
 */
 
contract MozoTreasury is BasicTreasury {
    /**
     * @dev Treasury constructor
     * @param _operation Operation smart contract
    */
    constructor(Operationable _operation) public BasicTreasury(_operation) {
    }
}