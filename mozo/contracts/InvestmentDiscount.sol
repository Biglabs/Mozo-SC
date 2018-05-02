pragma solidity 0.4.23;

import "./Sale.sol";
import "./Timeline.sol";

/**
 * @title InvestmentDiscount smart contract
 * @author Biglabs Pte. Ltd.
 * @dev Discounts will be based on amount invested
 */
 
contract InvestmentDiscount is Sale, Timeline {
    using SafeMath for uint;

    //wei contribution tranches
    uint[] public weiContributionTranches;

    //bonus percentage tranches
    uint[] public bonusPercentageTranches;

    modifier validContribution() {
        require(msg.value >= weiContributionTranches[0]);
        _;
    }

    /**
     * @notice owner should transfer to this smart contract Mozo sale tokens manually
     * @param _smzoToken ICO smart contract
     * @param  _weiContributionTranches Array of wei contribution tranches
     * @param _bonusPercentageTranches Array of bonus percentage tranches
     * @param _startTime The opening time in seconds (unix Time)
     * @param _endTime The closing time in seconds (unix Time)
    */
    function InvestmentDiscount(
        ICO _smzoToken,
        uint[] _weiContributionTranches,
        uint[] _bonusPercentageTranches,
        uint _startTime,
        uint _endTime
    )
    public
    Sale(_smzoToken)
    Timeline(_startTime, _endTime)
    onlyOwner()
    {
		uint weiLength = _weiContributionTranches.length - 1;
		uint bonusLength = _bonusPercentageTranches.length - 1;
		//at least 2 tranches, first tranche is min contribution
		require(weiLength > 0);
		require(weiLength == bonusLength);
	    require(_weiContributionTranches[0] >= 0);
	    require(_bonusPercentageTranches[0] >= 0);

        //require these arrays is sorted
		for (uint i=0; i < weiLength; i++) {
		    require(_weiContributionTranches[i] <= _weiContributionTranches[i+1]);
		    require(_bonusPercentageTranches[i] <= _bonusPercentageTranches[i+1]);
		}
		weiContributionTranches = _weiContributionTranches;
		bonusPercentageTranches = _bonusPercentageTranches;
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
        uint weiLength = weiContributionTranches.length;
        uint i = 0;
        for(; i < weiLength; i++) {
            if( msg.value < weiContributionTranches[i]) {
                break;
            }
        }

        uint tokenToFund = super._calculateToken();
        tokenToFund = tokenToFund.add(tokenToFund.mul(bonusPercentageTranches[i-1]).div(100));
        return tokenToFund;
    }
}
