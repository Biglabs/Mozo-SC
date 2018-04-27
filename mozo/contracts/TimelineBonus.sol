pragma solidity 0.4.23;

import "./Sale.sol";
import "./Timeline.sol";

/**
 * @title TimelineBonus smart contract
 * @author Biglabs Pte. Ltd.
 * @dev During bonus period, buyer will get bonus
 */
 
contract TimelineBonus is Sale, Timeline {
    using SafeMath for uint;

    //bonus duration
    uint public duration;

    //minimum wei contribution in bonus period
    uint public minContribution;

    //minimum wei contribution after period
    uint public minContributionAfterBonus;

    //BONUS PERCENTAGGE
    uint public bonusPercentage = 10;

    modifier validContribution() {
        if (now <= startTime.add(duration)) {
            require(msg.value >= minContribution);
        } else {
            if (now > startTime.add(duration)) {
                require(msg.value >= minContributionAfterBonus);
            }
        }
        _;
    }

    /**
     * @notice owner should transfer to this smart contract Mozo sale tokens manually
     * @param _smzoToken ICO smart contract
     * @param  _minContribution Minimum contribution in bonus period
     * @param _minContributionAfterBonus Minimum contribution after bonus period
     * @param _duration Bonus duration
     * @param _bonusPercentage Bonus percentage
     * @param _startTime The opening time in seconds (unix Time)
     * @param _endTime The closing time in seconds (unix Time)
    */
    function TimelineBonus(
        ICO _smzoToken,
        uint _minContribution,
        uint _minContributionAfterBonus,
        uint _duration,
        uint _bonusPercentage,
        uint _startTime,
        uint _endTime
    )
    public
    Sale(_smzoToken)
    Timeline(_startTime, _endTime)
    onlyOwner()
    {
        require(_duration > 0);
        require(_bonusPercentage >= 0);
        require(_minContribution >= 0);
        require(_minContributionAfterBonus >= 0);
        require(_startTime.add(duration) < _endTime);
        minContribution = _minContribution;
        minContributionAfterBonus = _minContributionAfterBonus;
        duration = _duration;
        bonusPercentage = _bonusPercentage;
    }

    /**
    * @dev Investor buy Sale Token use ETH
    */
    function buyToken() public onlyWhileOpen notClosed validContribution() payable returns (bool) {
        return Sale.buyToken();
    }
    
    /**
    * @dev Release smart contract
    */
    function release() public onlyOwner notClosed {
        _release();
    }

    /**
    * @dev Calculate number of tokens based on wei contribution
    */
    function _calculateToken() internal view returns (uint) {
        uint tokenToFund = super._calculateToken();
        if (now <= startTime.add(duration)) {
            tokenToFund = tokenToFund.add(tokenToFund.mul(bonusPercentage).div(100));
        }
        return tokenToFund;
    }


}
