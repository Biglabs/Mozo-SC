pragma solidity ^0.4.24;

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
    
    //no. tokens claimed
    uint internal claimedTokens = 0;

    /**
      * @dev RevocableVested constructor
      * @notice owner should transfer to this smart contract Mozo tokens manually
      * @param _mozoToken Mozo token smart contract
      * @param _beneficiary Beneficiary address
      * @param _start Starting
      * @param _cliff Cliff duration in seconds
      * @param _vestedDuration Vested duration in seconds
      *
     */
    constructor(
        OwnerERC20 _mozoToken,
        address _beneficiary,
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
        cliff = _start.add(_cliff);
        vestedDuration = _vestedDuration;
    }

    /**
     * @dev Get number of tokens
    */ 
    function noTokens() public view returns(uint) {
        return parent.balanceOf(address(this));
    }
    
    function totalTokens() public view returns(uint) {
        return parent.balanceOf(address(this)).add(claimedTokens);
    }

    /**
     * @dev Owner revoke contract 
     * 
    */
    function revoke() public onlyOwner notClosed {
        uint token = _calculateVested();
        //no vested token
        if (token <= 0) {
            parent.transfer(owner(), noTokens());
            _close();
            return;
        }
        
        _close();
        uint remain = noTokens().sub(token);
        parent.transfer(agency, token);
        //transfer remain tokens to owner
        if(remain > 0) {
            parent.transfer(owner(), remain);
        }
    }
    
    /**
     * @dev Get no. tokens claimed in advance
    */
    function getClaimedTokens() public view returns(uint) {
        return claimedTokens;
    }
    
    /**
     * @dev Beneficiary claim token in advance
     * @notice Consider whether we support this
    */
    function claimAdvance() public notClosed onlyAgency returns(uint) {
        uint token = _calculateVested();
        //no vested token
        if (token <= 0) {
            return 0;
        }
        
        claimedTokens = claimedTokens.add(token);
        parent.transfer(agency, token);
        return token;
    }


    /**
     * @dev Beneficiary claim token if not revoked
     * @notice Consider whether we support this
    */
    function claim() public notClosed isEnded onlyAgency {
        _close();
        parent.transfer(agency, noTokens());
    }

    /**
     * @dev Transfers the current balance to the owner and terminates the contract.
    */
    function destroy() onlyOwner requireClosed public {
        selfdestruct(owner());
    }

    /**
     * @dev Calculate number of vested token
     * 
    */

    function _calculateVested(uint _noTokens, uint _cliff, uint _vestedDuration, uint _time, uint _claimedTokens) public pure returns(uint) {
        //before cliff period, so zero token
        if (_time < _cliff) {
            return 0;
        }
        
        //without vested time, all tokens
        if (_vestedDuration == 0) {
            return _noTokens.sub(_claimedTokens);
        }

        uint t = _time.sub(_cliff);
        //after vested time, all tokens
        if (t > _vestedDuration) {
            return _noTokens.sub(_claimedTokens);
        }

        //linear with time passed
        return t.mul(_noTokens).div(_vestedDuration).sub(_claimedTokens);
        
    }
    
    /**
     * @dev Calculate number of vested token
     * 
    */
    function _calculateVested() internal view returns (uint) {
        return _calculateVested(totalTokens(), cliff, vestedDuration, now, getClaimedTokens());
    }
}