pragma solidity 0.4.23;

import "../../open-zeppelin/contracts/token/ERC20/BasicToken.sol";
import "./OwnerERC20.sol";
import "./ChainCoOwner.sol";
import "./ICO.sol";
import "./Timeline.sol";
import "./Upgradable.sol";

/**
 * @title Mozo sale token for ICO
 * @author Biglabs Pte. Ltd.
 */
 
contract MozoSaleToken is BasicToken, Timeline, ChainCoOwner, ICO {
    using SafeMath for uint;

    //sale token name, use in ICO phase only
    string public constant name = "Mozo Sale Token";

    //sale token symbol, use in ICO phase only
    string public constant symbol = "SMZO";

    //token symbol
    uint8 public constant decimals = 2;

    //indicate hardcap is reached or not
    bool public isCapped = false;

    //total wei collected
    uint public totalCapInWei;

    //rate
    uint public rate;

    //hold all address to transfer Mozo tokens when releasing
    address[] public transferAddresses;
    
    /**
     * Only onwer or smart contract of the same owner in chain.
    */
    modifier onlySameChain() {
        //check if function not called by owner or coOwner
        if (!isValidOwner(msg.sender)) {
            //require this called from smart contract
            ChainOwner sm = ChainOwner(msg.sender);
            //this will throw exception if not

            //ensure the same owner
            require(sm.owner() == owner());
        }
        _;
    }


    /**
     * @notice owner should transfer to this smart contract {_supply} Mozo tokens manually
     * @param _mozoToken Mozo token smart contract
     * @param _coOwner Array of coOwner
     * @param _supply Total number of tokens = No. tokens * 10^decimals = No. tokens * 100
     * @param _rate number of wei to buy 0.01 Mozo sale token
     * @param _openingTime The opening time in seconds (unix Time)
     * @param _closingTime The closing time in seconds (unix Time)
     */
    function MozoSaleToken(
        OwnerERC20 _mozoToken,
        address[] _coOwner,
        uint _supply,
        uint _rate,
        uint _openingTime,
        uint _closingTime
    )
        public
        ChainCoOwner(_mozoToken, _coOwner)
        Timeline(_openingTime, _closingTime)
        onlyOwner()
    {
        require(_supply > 0);
        require(_rate > 0);
        //check whether owner has enough tokens
        require(_mozoToken.balanceOf(msg.sender) >= _supply);
        rate = _rate;
        totalSupply_ = _supply;
        //assign all sale tokens to owner
        balances[_mozoToken.owner()] = totalSupply_;
        emit Transfer(0x0, _mozoToken.owner(), totalSupply_);
    }

    /**
     * @dev Get Rate: number of wei to buy 0.01 Mozo token
     */
    function getRate() public view returns (uint) {
        return rate;
    }

    /**
     * @dev Set Rate: 
     * @param _rate Number of wei to buy 0.01 Mozo token
     */
    function setRate(uint _rate) public onlyOwner {
        rate = _rate;
    }

    /**
     * @dev Get flag indicates ICO reached hardcap
     */
    function isReachCapped() public view returns(bool) {
        return isCapped;
    }

    /**
     * @dev Set hardcap is reached
     * @notice Owner must release all sale smart contracts
     */
    function setReachCapped() public onlyOwner {
        isCapped = true;
        _realease();
    }

    /**
     * @dev Get total distribution in Wei
     */
    function getCapInWei() public view returns (uint) {
        return totalCapInWei;
    }
    
    /**
     * @dev Get distributed tokens
    */
    function getDistributedToken() public view returns(uint) {
        return totalSupply_.sub(balances[owner()]);
    }

    /**
    * @dev Override transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint _value) public returns (bool) {
        //required this contract has enough Mozo tokens
        if (msg.sender == owner()) {
            require(parent.balanceOf(this) >= getDistributedToken().add(_value));
        }
        
        bool existing = balances[_to] > 0;
        if (BasicToken.transfer(_to, _value)) {
            if (!existing) {
                transferAddresses.push(_to);
            }
            return true;
        }
        return false;
    }

    /**
     * @param _weiAmount Contribution in wei
     * 
    */
    function calculateNoToken(uint _weiAmount) public view returns (uint) {
        return _weiAmount.div(rate);
    }
    /**
    * @dev Override transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _weiAmount The wei amount spent to by token
    */
    function transferByEth(address _to, uint _weiAmount, uint _value) 
        public 
        onlyWhileOpen 
        onlySameChain() 
        returns (bool) 
    {
        if (transfer(_to, _value)) {
            totalCapInWei = totalCapInWei.add(_weiAmount);
            return true;
        }
        return false;
    }

    /**
     * @dev Release smart contract
     * @notice Owner must release all sale smart contracts
    */
    function release() public onlyOwner {
        _realease();
    }
    
    /**
     * @dev Investor claim tokens
    */
    function claim() public isEnded {
        require(balances[msg.sender] > 0);
        uint b = balances[msg.sender];
        balances[msg.sender] = 0;
        parent.transfer(msg.sender, b);
    }
    
    //factory
    /**
     * @dev Call this to upgrade referral smart contract
    */
    function upgradeReferral(address _referral) public onlyOwner {
        Upgradable sc = Upgradable(_referral);
        
        uint _value = sc.getRequiredTokens(sc.getLevel()+1);
        if (transfer(_referral, _value)) {
            sc.upgrade(); 
        }
    }

    /**
     * @notice Only call after releasing all sale smart contracts
     * @dev Release smart contract
     */
    function _realease() internal {
        uint len = transferAddresses.length;

        if (isCapped) {
            //Reach hardcap, burn all owner sale token
            for (uint i = 0; i < len; i++) {
                address ad = transferAddresses[i];
                if (ad == owner()) {
                    continue;
                }
                uint b = balances[ad];
                if (b == 0) {
                    continue;
                }

                balances[ad] = 0;
                // send Mozo token from ICO account to investor address
                parent.transfer(ad, b);
            }
        } else {
            uint unsold = balances[owner()];
            uint sold = totalSupply_.sub(unsold);
            if (sold <= 0) {
                //very bad if we reach here
                return;
            }
            for (i = 0; i < len; i++) {
                ad = transferAddresses[i];
                if (ad == owner()) {
                    continue;
                }
                b = balances[ad];
                if (b == 0) {
                    continue;
                }
                //distribute all unsold token to investors
                b = b.add(b.mul(unsold).div(sold));

                // send Mozo token from ICO account to investor address
                balances[ad] = 0;
                parent.transfer(ad, b);
            }
        }
        //transfer remain tokens to owner
        //for testing only
        //parent.transfer(owner(), parent.balanceOf(address(this)));
    }
}
