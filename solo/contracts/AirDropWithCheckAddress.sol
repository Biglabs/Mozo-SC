pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./Airdrop.sol";
import "../../common/contracts/UsingAddress.sol";

/**
 * @title Airdrop for retailer tokens
 * @author Biglabs Pte. Ltd.
 */

contract AirdropWithCheckAddress is Airdrop, UsingAddress {
    using SafeMath for uint;

    /**
     * @dev Airdrop for retailer constructor
     * @param _operation Operation smart contract
     * @param _airdrop Number of SOLO to airdrop for retailer
     * @param _startTime The opening time in seconds (unix Time)
     * @param _endTime The closing time in seconds (unix Time)
    */
    constructor(Operationable _operation, uint _airdrop, uint _startTime, uint _endTime) public Airdrop(_operation, _airdrop, _startTime, _endTime) {
    }
    
    /**
     * @dev Call by Bridge to get airdrop
     * @param _to Address of receiver
     */
	function doAirdrop(address _to) public onlyOperation onlyWhileOpen checkAddressUsed(_to) returns(bool) {
	    Airdrop._doAirdrop(_to);
	}
}
