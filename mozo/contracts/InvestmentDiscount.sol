pragma solidity 0.4.23;

import "./Sale.sol";
import "./Timeline.sol";
import "./ContributionBonus.sol";

/**
 * @title InvestmentDiscount smart contract
 * @author Biglabs Pte. Ltd.
 * @dev Discounts will be based on amount invested
 */
 
contract InvestmentDiscount is Sale, ContributionBonus, Timeline {
    using SafeMath for uint;

    /**
     * @notice owner should transfer to this smart contract Mozo sale tokens manually
     * and add this smart contract to ICO whitelist
     * @param _smzoToken ICO smart contract
     * @param  _weiContributionTranches Array of wei contribution tranches
     * @param _bonusPercentageTranches Array of bonus percentage tranches
     * @param _startTime The opening time in seconds (unix Time)
     * @param _endTime The closing time in seconds (unix Time)
    */
    constructor(
        ICO _smzoToken,
        uint[] _weiContributionTranches,
        uint[] _bonusPercentageTranches,
        uint _startTime,
        uint _endTime
    )
    public
    Sale(_smzoToken)
    ContributionBonus(_weiContributionTranches, _bonusPercentageTranches)
    Timeline(_startTime, _endTime)
    onlyOwner()
    {
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
        uint i = _getTranche();

        uint tokenToFund = super._calculateToken();
        tokenToFund = tokenToFund.add(tokenToFund.mul(bonusPercentageTranches[i]).div(100));
        return tokenToFund;
    }
}
