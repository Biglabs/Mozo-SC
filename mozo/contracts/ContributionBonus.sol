pragma solidity ^0.4.24;

/**
 * @title ContributionBonus smart contract
 * @author Biglabs Pte. Ltd.
 * @dev Discounts will be based on amount invested
 */
 
contract ContributionBonus {
    //wei contribution tranches
    uint[] public weiContributionTranches;

    //bonus percentage tranches
    uint[] public bonusPercentageTranches;

    modifier validContribution() {
        require(msg.value >= weiContributionTranches[0]);
        _;
    }

    /**
     * @param  _weiContributionTranches Array of wei contribution tranches
     * @param _bonusPercentageTranches Array of bonus percentage tranches
    */
    constructor(
        uint[] _weiContributionTranches,
        uint[] _bonusPercentageTranches
    )
    internal
    {
		uint weiLength = _weiContributionTranches.length - 1;
		uint bonusLength = _bonusPercentageTranches.length - 1;
		//at least 2 tranches, first tranche is min contribution
		require(weiLength > 0);
		require(weiLength == bonusLength);

        //require these arrays is sorted
		for (uint i=0; i < weiLength; i++) {
		    require(_weiContributionTranches[i] <= _weiContributionTranches[i+1]);
		    require(_bonusPercentageTranches[i] <= _bonusPercentageTranches[i+1]);
		}
		weiContributionTranches = _weiContributionTranches;
		bonusPercentageTranches = _bonusPercentageTranches;
    }


    /**
    * @dev Get the tranche based on wei contribution
    */
    function _getTranche() internal view returns (uint) {
        uint weiLength = weiContributionTranches.length;
        uint i = 0;
        for (;i < weiLength; i++) {
            if (msg.value < weiContributionTranches[i]) {
                break;
            }
        }
        require(i > 0);
        
        return i-1;
    }
}
