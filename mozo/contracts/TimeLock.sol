pragma solidity 0.4.23;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./Timeline.sol";
import "./ChainOwner.sol";
import "./Agentable.sol";

/**
 * @title Time lock smart contract
 * @author Biglabs Pte. Ltd.
*/

contract TimeLock is Timeline, ChainOwner, Agentable {
    using SafeMath for uint;

    //no. tokens
    uint public total;

    /**
     * @dev TimeLock constructor
     * @notice owner should transfer to this smart contract {_total} Mozo tokens manually
     * @param _mozoToken Mozo token smart contract
     * @param _beneficiary Beneficiary address
     * @param _total Number of tokens = No. tokens * 10^decimals = No. tokens * 100
     * @param _start Starting (unix Time)
     * @param _lockPeriod Locking period in seconds
     * 
    */
    function TimeLock(OwnerERC20 _mozoToken, address _beneficiary, uint _total, uint _start, uint _lockPeriod) 
        public 
        Timeline(_start, _start.add(_lockPeriod))
        ChainOwner(_mozoToken) 
        Agentable(_beneficiary)
        onlyOwner() 
    {
        require(_total > 0);
        //chech whether owner has enough tokens
        require(_mozoToken.balanceOf(msg.sender) >= _total);
        
        total = _total;
    }
    
    /**
     * @dev Check whether founder sent token to this smart contract
    */ 
    function isValid() public view returns(bool) {
        return parent.balanceOf(address(this)) >= total;
    }
    
    /**
     * @notice not support payable
    */
    function() public payable {
        revert();
    }

    /**
     * @dev Transfers tokens held by timelock to beneficiary.
    */
    function release() public isEnded {
        uint vested = total;
        total = 0;
        parent.transfer(agency, vested);
    }

}
