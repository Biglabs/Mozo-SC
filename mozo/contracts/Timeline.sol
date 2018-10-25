pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/math/SafeMath.sol";

/**
 * @title Utility smart contracts
 * @author Biglabs Pte. Ltd.
 * @dev Timeline smart contract (within the period)
 */
 
contract Timeline {
    //start time
    uint public startTime;

    //end time
    uint public endTime;

    modifier started() {
        require(now >= startTime);
        _;
    }

    modifier notEnded() {
        require(now <= endTime);
        _;
    }

    modifier isEnded() {
        require(now >= endTime);
        _;
    }

    modifier onlyWhileOpen() {
        require(isOpened());
        _;
    }


    /**
     * @dev Timeline constructor
     * @param _startTime The opening time in seconds (unix Time)
     * @param _endTime The closing time in seconds (unix Time)
     */
    constructor(
        uint256 _startTime,
        uint256 _endTime
    )
        public 
    {
        require(_startTime > now);
        require(_endTime > _startTime);
        startTime = _startTime;
        endTime = _endTime;
    }

    function isOpened() public view returns(bool) {
        return (now >= startTime && now <= endTime);
    }
}

