pragma solidity 0.4.23;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./Sale.sol";
import "./Timeline.sol";
import "./Agentable.sol";
import "./Upgradable.sol";

/**
 * @title Referral program smart contract
 * @author Biglabs Pte. Ltd.
 * @dev Referral with five packages start at 10k tokens
 * Owner can upgrade package
 */
 
contract Referral is Sale, Timeline, Agentable, Upgradable {
    using SafeMath for uint;

    //curent level
    uint public level;

    //minimum wei contribution
    uint public minContribution;

    //package tokens
    uint private constant PACKAGE_1 = 5000000;
    uint private constant PACKAGE_2 = 10000000;
    uint private constant PACKAGE_3 = 100000000;
    uint private constant PACKAGE_4 = 1000000000;
    uint private constant PACKAGE_5 = 10000000000;

    //package tokens
    uint private constant PACKAGE_1_MINIMUM = 100000000000000000;//0.1 eth
    uint private constant PACKAGE_2_MINIMUM = 100000000000000000;//0.1 eth
    uint private constant PACKAGE_3_MINIMUM = 100000000000000000;//0.1 eth
    uint private constant PACKAGE_4_MINIMUM = 100000000000000000;//0.1 eth
    uint private constant PACKAGE_5_MINIMUM = 100000000000000000;//0.1 eth

    //BONUS PERCENTAGGE
    uint private constant BONUS_PERCENT_LEVEL_1 = 10;
    uint private constant BONUS_PERCENT_LEVEL_2 = 12;
    uint private constant BONUS_PERCENT_LEVEL_3 = 14;
    uint private constant BONUS_PERCENT_LEVEL_4 = 16;
    uint private constant BONUS_PERCENT_LEVEL_5 = 18;

    //bonus tokens
    uint private constant PACKAGE_1_BONUS = PACKAGE_1 * BONUS_PERCENT_LEVEL_1 / 100;
    uint private constant PACKAGE_2_BONUS = PACKAGE_2 * BONUS_PERCENT_LEVEL_2 / 100;
    uint private constant PACKAGE_3_BONUS = PACKAGE_3 * BONUS_PERCENT_LEVEL_3 / 100;
    uint private constant PACKAGE_4_BONUS = PACKAGE_4 * BONUS_PERCENT_LEVEL_4 / 100;
    uint private constant PACKAGE_5_BONUS = PACKAGE_5 * BONUS_PERCENT_LEVEL_5 / 100;

    //package tokens
    uint private constant PACKAGE_1_TOKENS = PACKAGE_1 + PACKAGE_1_BONUS;
    uint private constant PACKAGE_2_TOKENS = PACKAGE_2 + PACKAGE_2_BONUS;
    uint private constant PACKAGE_3_TOKENS = PACKAGE_3 + PACKAGE_3_BONUS;
    uint private constant PACKAGE_4_TOKENS = PACKAGE_4 + PACKAGE_4_BONUS;
    uint private constant PACKAGE_5_TOKENS = PACKAGE_5 + PACKAGE_5_BONUS;

    //upgrade required tokens
    uint private constant PACKAGE_1_TOKENS_REQUIRE = PACKAGE_1_TOKENS;
    uint private constant PACKAGE_2_TOKENS_REQUIRE = PACKAGE_2_TOKENS - PACKAGE_1_TOKENS;
    uint private constant PACKAGE_3_TOKENS_REQUIRE = PACKAGE_3_TOKENS - PACKAGE_2_TOKENS;
    uint private constant PACKAGE_4_TOKENS_REQUIRE = PACKAGE_4_TOKENS - PACKAGE_3_TOKENS;
    uint private constant PACKAGE_5_TOKENS_REQUIRE = PACKAGE_5_TOKENS - PACKAGE_4_TOKENS;

    modifier validContribution() {
        require(msg.value >= minContribution);
        _;
    }

    modifier canUpgrade() {
        require(level < 5);
        _;
    }

    /**
      * constructor
      * @notice owner should transfer to this smart contract getRequiredTokens(1) Mozo sale tokens manually
      * @param _smzoToken ICO smart contract
      * @param _agency Ethereum wallet address of agency
      * @param _startTime The opening time in seconds (unix Time)
      * @param _endTime The closing time in seconds (unix Time)
     */
    function Referral(
        ICO _smzoToken,
        address _agency,
        uint _startTime,
        uint _endTime
    )
    public
    Sale(_smzoToken)
    Timeline(_startTime, _endTime)
    Agentable(_agency)
    onlyOwner()
    {
        //check whether owner has enough tokens
        require(_smzoToken.balanceOf(msg.sender) >= getRequiredTokens(1));
        level = 1;
        minContribution = PACKAGE_1_MINIMUM;
    }


    //Investor buy Sale Token use ETH
    function buyToken() public onlyWhileOpen notClosed validContribution notAgency payable returns (bool) {
        return Sale.buyToken();
    }

    /**
     * @notice Should use factory function from MozoSaleToken
     * If Owner call transfer and this function manually
     * it may lead to inconsistent state
     * @dev Upgrade level
     */
    function upgrade() public notClosed canUpgrade validOwner(parent) {
        level = level.add(1);
        minContribution = getMinimumContribution(level);
    }

    function getLevel() public view returns (uint) {
        return level;
    }

    function getBonusTokens(uint _level) public pure returns (uint) {
        if (_level == 1) {
            return PACKAGE_1_BONUS;
        }

        if (_level == 2) {
            return PACKAGE_2_BONUS;
        }

        if (_level == 3) {
            return PACKAGE_3_BONUS;
        }

        if (_level == 4) {
            return PACKAGE_4_BONUS;
        }

        return PACKAGE_5_TOKENS_REQUIRE;
    }

    function getRequiredTokens(uint _level) public pure returns (uint) {
        if (_level == 1) {
            return PACKAGE_1_TOKENS_REQUIRE;
        }

        if (_level == 2) {
            return PACKAGE_2_TOKENS_REQUIRE;
        }

        if (_level == 3) {
            return PACKAGE_3_TOKENS_REQUIRE;
        }

        if (_level == 4) {
            return PACKAGE_4_TOKENS_REQUIRE;
        }

        return PACKAGE_5_TOKENS_REQUIRE;
    }


    function getRealBonusPercentage(uint _sold) public pure returns (uint) {
        if (_sold <= PACKAGE_1) {
            return BONUS_PERCENT_LEVEL_1;
        }

        if (_sold <= PACKAGE_2) {
            return BONUS_PERCENT_LEVEL_2;
        }

        if (_sold <= PACKAGE_3) {
            return BONUS_PERCENT_LEVEL_3;
        }

        if (_sold <= PACKAGE_4) {
            return BONUS_PERCENT_LEVEL_4;
        }

        return BONUS_PERCENT_LEVEL_5;
    }

    function getBonusPercentage(uint _level) public pure returns (uint) {
        if (_level == 1) {
            return BONUS_PERCENT_LEVEL_1;
        }

        if (_level == 2) {
            return BONUS_PERCENT_LEVEL_2;
        }

        if (_level == 3) {
            return BONUS_PERCENT_LEVEL_3;
        }

        if (_level == 4) {
            return BONUS_PERCENT_LEVEL_4;
        }

        return BONUS_PERCENT_LEVEL_5;
    }

    function getMinimumContribution(uint _level) public pure returns (uint) {
        if (_level == 1) {
            return PACKAGE_1_MINIMUM;
        }

        if (_level == 2) {
            return PACKAGE_2_MINIMUM;
        }

        if (_level == 3) {
            return PACKAGE_3_MINIMUM;

        }

        if (_level == 4) {
            return PACKAGE_4_MINIMUM;
        }

        return PACKAGE_5_MINIMUM;
    }

    function getTotalToken(uint _level) public pure returns (uint) {
        if (_level == 1) {
            return PACKAGE_1_TOKENS;
        }

        if (_level == 2) {
            return PACKAGE_2_TOKENS;
        }

        if (_level == 3) {
            return PACKAGE_3_TOKENS;

        }

        if (_level == 4) {
            return PACKAGE_4_TOKENS;
        }

        return PACKAGE_5_TOKENS;
    }

    function getPackageToken(uint _level) public pure returns (uint) {
        if (_level == 1) {
            return PACKAGE_1;
        }

        if (_level == 2) {
            return PACKAGE_2;
        }

        if (_level == 3) {
            return PACKAGE_3;

        }

        if (_level == 4) {
            return PACKAGE_4;
        }

        return PACKAGE_5;
    }

    //Release this smartcontract
    function release() public onlyOwner notClosed {
        _release();
    }

    //Claim this smartcontract
    function claim() public isEnded notClosed onlyAgency {
        _release();
    }

    /**
    * @dev Check whether tokens is enough for buying
    */
    function _checkNoToken(uint _value) internal view {
        uint newSold = sold.add(_value);
        require(_value <= noTokens().sub(getRealBonusPercentage(newSold).mul(newSold).div(100)));
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
        return getRealBonusPercentage(sold).mul(sold).div(100);
    }
}

