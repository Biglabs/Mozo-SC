pragma solidity 0.4.23;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./Timeline.sol";
import "./ChainOwner.sol";
import "./Closable.sol";
import "./Agentable.sol";

/**
 * @title Revocable Vested smart contract
 * @author Biglabs Pte. Ltd.
*/

contract RevocableVested is Timeline, ChainOwner, Closable, Agentable {
    using SafeMath for uint;

    //start
    uint public vestedDuration;

    //cliff duration
    uint public cliff;

    //end
    uint public total;

    /**
      * @dev RevocableVested constructor
      * @notice owner should transfer to this smart contract {_total} Mozo tokens manually
      * @param _mozoToken Mozo token smart contract
      * @param _beneficiary Beneficiary address
      * @param _total Number of tokens = No. tokens * 10^decimals = No. tokens * 100
      * @param _start Starting
      * @param _cliff Cliff duration in seconds
      * @param _vestedDuration Vested duration in seconds
      *
     */
    function RevocableVested(
        OwnerERC20 _mozoToken,
        address _beneficiary,
        uint _total,
        uint _start,
        uint _cliff,
        uint _vestedDuration
    )
        public
        Timeline(_start, _start.add(cliff).add(_vestedDuration))
        ChainOwner(_mozoToken)
        Agentable(_beneficiary)
        onlyOwner()
    {
        require(cliff >= 0);
        require(_vestedDuration >= 0);
        require(_total > 0);
        //check whether owner has enough tokens
        require(_mozoToken.balanceOf(msg.sender) >= _total);
        
        cliff = _start.add(_cliff);
        vestedDuration = _vestedDuration;
        total = _total;
    }

    /**
     * @dev Check whether founder sent token to this smart contract
    */ 
    function isValid() public view returns(bool) {
        return parent.balanceOf(address(this)) >= total;
    }

    /**
     * @dev not support payable
    */
    function() public payable {
        revert();
    }

    /**
     * @dev Owner revoke contract 
     * 
    */
    function revoke() public onlyOwner notClosed {
        uint token = _calculateVested();
        //no vested token
        if (token <= 0) {
            parent.transfer(owner(), total);
            close();
            return;
        }
        
        if (token > total) {
            token = total;
        }

        close();
        uint remain = total.sub(token);
        parent.transfer(agency, token);
        //transfer remain tokens to owner
        if(remain > 0) {
            parent.transfer(owner(), remain);
        }
    }

    /**
     * @dev Beneficiary claim token if not revoked
     * @notice Consider whether we support this
    */
    function claim() public notClosed isEnded onlyAgency {
        close();
        parent.transfer(agency, total);
    }

    /**
     * @dev Calculate number of vested token
     * 
    */
    function _calculateVested() internal view returns (uint) {
        //before cliff period, so zero token
        if (now < cliff) {
            return 0;
        }
        
        //without vested time, all tokens
        if (vestedDuration == 0) {
            return total;
        }

        uint time = now.sub(cliff);
        //after vested time, all tokens
        if (time > vestedDuration) {
            return total;
        }

        //linear with time passed
        return time.mul(total).div(vestedDuration);
    }
}