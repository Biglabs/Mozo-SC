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

    //KYC/AML threshold: 20k SGD = 15k USD = 165k token (x100)
    uint public constant AML_THRESHOLD = 16500000;

    //No. repicients that has bonus tokens
    uint public noBonusTokenRecipients;

    //total no. bonus tokens
    uint public totalBonusToken;

    //bonus transferred flags
    mapping(address => bool) bonus_transferred_repicients;

    //maximum transferring per function
    uint public constant MAX_TRANSFER = 80;

    //number of transferred address
    uint public transferredIndex;

    //indicate hardcap is reached or not
    bool public isCapped = false;

    //total wei collected
    uint public totalCapInWei;

    //rate
    uint public rate;

    //flag indicate whether ICO is stopped for bonus
    bool public isStopped;

    //hold all address to transfer Mozo tokens when releasing
    address[] public transferAddresses;

    //whitelist (Already register KYC/AML)
    mapping(address => bool) public whitelist;

    //contain map of address that buy over the threshold for KYC/AML 
    //but buyer is not in the whitelist yes
    mapping(address => uint) public pendingAmounts;

    /**
     * @dev Throws if called by any account that's not whitelisted.
     */
    modifier onlyWhitelisted() {
        require(whitelist[msg.sender]);
        _;
    }

    /**
     * @dev Only owner or coOwner
    */
    modifier onlyOwnerOrCoOwner() {
        require(isValidOwner(msg.sender));
        _;
    }

    /**
     * @dev Only stopping for bonus distribution
    */
    modifier onlyStopping() {
        require(isStopped == true);
        _;
    }

    /**
     * Only owner or smart contract of the same owner in chain.
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

        //add owner and co_owner to whitelist
        addAddressToWhitelist(msg.sender);
        addAddressesToWhitelist(_coOwner);
        emit Transfer(0x0, _mozoToken.owner(), totalSupply_);
    }
    
    function addCoOwners(address[] _coOwner) public onlyOwner {
        _addCoOwners(_coOwner);
    }

    function addCoOwner(address _coOwner) public onlyOwner {
        _addCoOwner(_coOwner);
    }

    function disableCoOwners(address[] _coOwner) public onlyOwner {
        _disableCoOwners(_coOwner);
    }

    function disableCoOwner(address _coOwner) public onlyOwner {
        _disableCoOwner(_coOwner);
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
    function setRate(uint _rate) public onlyOwnerOrCoOwner {
        rate = _rate;
    }

    /**
     * @dev Get flag indicates ICO reached hardcap
     */
    function isReachCapped() public view returns (bool) {
        return isCapped;
    }

    /**
     * @dev add an address to the whitelist, sender must have enough tokens
     * @param _address address for adding to whitelist
     * @return true if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToWhitelist(address _address) onlyOwnerOrCoOwner public returns (bool success) {
        if (!whitelist[_address]) {
            whitelist[_address] = true;
            //transfer pending amount of tokens to user
            uint noOfTokens = pendingAmounts[_address];
            if (noOfTokens > 0) {
                pendingAmounts[_address] = 0;
                transfer(_address, noOfTokens);
            }
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist, sender must have enough tokens
     * @param _addresses addresses for adding to whitelist
     * @return true if at least one address was added to the whitelist, 
     * false if all addresses were already in the whitelist  
     */
    function addAddressesToWhitelist(address[] _addresses) onlyOwnerOrCoOwner public returns (bool success) {
        uint length = _addresses.length;
        for (uint i = 0; i < length; i++) {
            if (addAddressToWhitelist(_addresses[i])) {
                success = true;
            }
        }
    }

    /**
     * @dev remove an address from the whitelist
     * @param _address address
     * @return true if the address was removed from the whitelist, 
     * false if the address wasn't in the whitelist in the first place 
     */
    function removeAddressFromWhitelist(address _address) onlyOwnerOrCoOwner public returns (bool success) {
        if (whitelist[_address]) {
            whitelist[_address] = false;
            success = true;
        }
    }

    /**
     * @dev remove addresses from the whitelist
     * @param _addresses addresses
     * @return true if at least one address was removed from the whitelist, 
     * false if all addresses weren't in the whitelist in the first place
     */
    function removeAddressesFromWhitelist(address[] _addresses) onlyOwnerOrCoOwner public returns (bool success) {
        uint length = _addresses.length;
        for (uint i = 0; i < length; i++) {
            if (removeAddressFromWhitelist(_addresses[i])) {
                success = true;
            }
        }
    }

    /**
     * Stop selling for bonus transfer
     * @notice Owner should release InvestmentDiscount smart contract before call this
     */
    function setStop() onlyOwnerOrCoOwner {
        isStopped = true;
    }

    /**
     * @dev Set hardcap is reached
     * @notice Owner must release all sale smart contracts
     */
    function setReachCapped() public onlyOwnerOrCoOwner {
        isCapped = true;
    }

    /**
     * @dev Get total distribution in Wei
     */
    function getCapInWei() public view returns (uint) {
        return totalCapInWei;
    }

    /**
     * @dev Get no. investors
     */
    function getNoInvestor() public view returns (uint) {
        return transferAddresses.length;
    }

    /**
     * @dev Get unsold tokens
     */
    function getUnsoldToken() public view returns (uint) {
        uint unsold = balances[owner()];
        for (uint j = 0; j < coOwnerList.length; j++) {
            unsold = unsold.add(balances[coOwnerList[j]]);
        }

        return unsold;
    }

    /**
     * @dev Get distributed tokens
     */
    function getDistributedToken() public view returns (uint) {
        return totalSupply_.sub(getUnsoldToken());
    }

    /**
     * @dev Override transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint _value) public returns (bool) {
        //required this contract has enough Mozo tokens
        //obsolete
        //if (msg.sender == owner()) {
        //    require(parent.balanceOf(this) >= getDistributedToken().add(_value));
        //}
        //we will check it when releasing smart contract

        //owners or balances already greater than 0, no need to add to list
        bool notAddToList = isValidOwner(_to) || (balances[_to] > 0);

        //check AML threshold
        if (!isStopped) {
            if (!whitelist[_to]) {
                if ((_value + balances[_to]) > AML_THRESHOLD) {
                    pendingAmounts[_to] = pendingAmounts[_to].add(_value);
                    return true;
                }
            }
        }

        if (BasicToken.transfer(_to, _value)) {
            if (!notAddToList) {
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
    function release() public onlyOwnerOrCoOwner {
        _release();
    }

    /**
     * @dev Investor claim tokens
     */
    function claim() public isEnded {
        require(balances[msg.sender] > 0);
        uint investorBalance = balances[msg.sender];

        balances[msg.sender] = 0;
        parent.transfer(msg.sender, investorBalance);
    }

    /**
     * @param _recipients list of repicients
     * @param _amount list of no. tokens
    */
    function bonusToken(address[] _recipients, uint[] _amount) public onlyOwnerOrCoOwner onlyStopping {
        uint len = _recipients.length;
        uint len1 = _amount.length;
        require(len == len1);
        require(len <= MAX_TRANSFER);
        uint i;
        uint total = 0;
        for (i = 0; i < len; i++) {
            if (bonus_transferred_repicients[_recipients[i]] == false) {
                bonus_transferred_repicients[_recipients[i]] = transfer(_recipients[i], _amount[i]);
                total = total.add(_amount[i]);
            }
        }
        totalBonusToken = totalBonusToken.add(total);
        noBonusTokenRecipients = noBonusTokenRecipients.add(len);
    }

    function min(uint a, uint b) internal pure returns (uint) {
        return a < b ? a : b;
    }

    /**
     * @notice Only call after releasing all sale smart contracts, this smart contract must have enough Mozo tokens
     * @dev Release smart contract
     */
    function _release() internal {
        uint length = min(transferAddresses.length, transferredIndex + MAX_TRANSFER);
        uint i = transferredIndex;

        if (isCapped) {
            //Reach hardcap, burn all owner sale token
            for (; i < length; i++) {
                address ad = transferAddresses[i];
                uint b = balances[ad];
                if (b == 0) {
                    continue;
                }

                balances[ad] = 0;
                // send Mozo token from ICO account to investor address
                parent.transfer(ad, b);
            }
        } else {
            uint unsold = getUnsoldToken();
            uint sold = totalSupply_.sub(unsold);

            if (sold <= 0) {
                //very bad if we reach here
                return;
            }
            for (; i < length; i++) {
                ad = transferAddresses[i];
                //obsolete
                //no need to check because we checked before adding
                //if (ad == owner()) {
                //    continue;
                //}
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

        transferredIndex = i - 1;

        //transfer remain tokens to owner
        //for testing only
        //parent.transfer(owner(), parent.balanceOf(address(this)));
    }

}
