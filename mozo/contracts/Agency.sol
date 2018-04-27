pragma solidity 0.4.23;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./Sale.sol";
import "./Timeline.sol";
import "./Agentable.sol";
/**
 * @title Presale Agency smart contract
 * @author Biglabs Pte. Ltd.
 * @dev These contracts will be created by Founder in presale. 
 * When smart contract is released by Owner, bonus sale token will be transferred to agency.
 * Owner can refill (add more number of tokens by transferring more tokens)
 * Agency can claim when smart contract ended (in case owner did not release)
 */


contract Agency is Sale, Timeline, Agentable {
    using SafeMath for uint;

    //minimum wei contribution
    uint public minContribution;

    //BONUS PERCENTAGGE
    uint public bonusPercentage;

    modifier validContribution() {
        require(msg.value >= minContribution);
        _;
    }

    /**
     * @notice owner should transfer to this smart contract Mozo sale tokens manually
     * @param _smzoToken ICO smart contract
     * @param _agency Ethereum wallet address of agency
     * @param _minContribution Minimum contribution in wei
     * @param _bonusPercentage Bonus percentage for agency (10 means 10%)
     * @param _startTime The opening time in seconds (unix Time)
     * @param _endTime The closing time in seconds (unix Time)
     */
    function Agency(
        ICO _smzoToken,
        address _agency,
        uint _minContribution,
        uint _bonusPercentage,
        uint _startTime,
        uint _endTime
    )
    public
    Sale(_smzoToken)
    Timeline(_startTime, _endTime)
    Agentable(_agency)
    onlyOwner()
    {
        require(_minContribution >= 0);
        require(_bonusPercentage >= 0);
        minContribution = _minContribution;
        bonusPercentage = _bonusPercentage;
    }

    /**
    * @dev Investor buy Sale Token use ETH
    */
    function buyToken() public onlyWhileOpen notClosed validContribution notAgency payable returns (bool) {
        return Sale.buyToken();
    }

    /**
    * @dev Release the contract
    */
    function release() public started onlyOwner notClosed {
        _release();
    }

    /**
    * @dev Claim this smartcontract
    */
    function claim() public isEnded notClosed onlyAgency {
        _release();
    }
    
    /**
     * @dev Apply bonus policy: based on sold tokens
    */
    function _bonusProcess() internal {
        ico().transfer(agency, _holdTokens());
    }
    
    /**
     * @dev Calculate number of tokens to be held
    */
    function _holdTokens() internal view returns(uint) {
        return bonusPercentage.mul(sold).div(100);
    }
    
    /**
    * @dev Check whether tokens is enough for buying
    */
    function _checkNoToken(uint _value) internal view {
        require(_value <= noTokens().sub(bonusPercentage.mul(sold.add(_value)).div(100)));
    }

}

