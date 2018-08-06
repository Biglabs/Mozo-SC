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

    /**
     * @dev TimeLock constructor
     * @notice owner should transfer to this smart contract Mozo tokens manually
     * @param _mozoToken Mozo token smart contract
     * @param _beneficiary Beneficiary address
     * @param _start Starting (unix Time)
     * @param _lockPeriod Locking period in seconds
     * 
    */
    constructor(OwnerERC20 _mozoToken, address _beneficiary, uint _start, uint _lockPeriod) 
        public 
        Timeline(_start, _start.add(_lockPeriod))
        ChainOwner(_mozoToken) 
        Agentable(_beneficiary)
        onlyOwner() 
    {
    }
    
    /**
     * @dev Get number of tokens
    */ 
    function noTokens() public view returns(uint) {
        return parent.balanceOf(address(this));
    }

    /**
     * @dev Transfers tokens held by timelock to beneficiary.
    */
    function release() public isEnded {
        parent.transfer(agency, noTokens());
    }

    /**
     * @dev Transfers tokens held by timelock to beneficiary and terminates the contract.
    */
    function destroy() onlyOwner isEnded public {
        release();
        selfdestruct(owner());
    }
}
