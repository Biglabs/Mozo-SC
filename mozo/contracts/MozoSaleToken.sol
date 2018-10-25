pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/token/ERC20/BasicToken.sol";
import "./OwnerERC20.sol";
import "./ChainCoOwner.sol";
import "./ICO.sol";
import "./Timeline.sol";

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

    //token decimals
    uint8 public constant decimals = 2;

    //KYC/AML threshold: 20k SGD = 15k USD = 165k token (x100)
    uint public constant AML_THRESHOLD = 16500000;

    //No. repicients that has bonus tokens
    uint public noBonusTokenRecipients;

    //total no. bonus tokens
    uint public totalBonusToken;

    //bonus transferred flags
    mapping(address => bool) public bonus_transferred_recipients;

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

    //used for check investor address
    mapping(address => bool) public isInvestorAddresses;

    //whitelist (Already register KYC/AML)
    mapping(address => bool) public whitelist;

    //Sale smart contracts
    mapping(address => bool) public sales;

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
     * @dev Only sale smart contracts
    */
    modifier onlySale() {
        require(sales[msg.sender]);
        _;
    }

    /**
     * @dev for checking when adding co-owner
    */
    modifier notInvestor(address _address) {
        require(!isInvestorAddresses[_address]);
        _;
    }

    /**
     * @dev check AML threshold
    */

    modifier checkAML(address _from, address _to, uint _value) {
        //if stopped (after all sale smart contracts is released), we dont want to check AML
        if (isStopped) {
            _;
            return;
        }
        //if _from is not owner/co-owner/sale smart contracts, we dont check AML
        //means investor can transfer tokens to other after AML process
        if (!isValidOwner(_from) && !sales[_from]) {
            _;
            return;
        }

        //if _to is in whitelist or sale or owner, ignore
        if (whitelist[_to] || sales[_to] || isValidOwner(_to)) {
            _;
            return;
        }

        //owner/co-owner/sale smart contract transfer token
        //required AML process and adding {_to} to whitelist
        require((_value + balances[_to]) < AML_THRESHOLD);
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
    constructor(
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

        rate = _rate;
        totalSupply_ = _supply;

        //assign all sale tokens to owner
        balances[_mozoToken.owner()] = totalSupply_;

        emit Transfer(0x0, _mozoToken.owner(), totalSupply_);
    }

    function addCoOwners(address[] _coOwner) public onlyOwner {
        uint length = _coOwner.length;
        for (uint i = 0; i < length; i++) {
            addCoOwner(_coOwner[i]);
        }
    }

    function addCoOwner(address _coOwner) public onlyOwner notInvestor(_coOwner) {
        _addCoOwner(_coOwner);
    }

    function disableCoOwners(address[] _coOwner) public onlyOwner {
        uint length = _coOwner.length;
        for (uint i = 0; i < length; i++) {
            disableCoOwner(_coOwner[i]);
        }
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
     * @dev add sale smart contract address
     * @param _address address of sale smart contract
     * @return true if the address was added, false if the address was already
     */
    function addSaleAddress(address _address) onlyOwnerOrCoOwner public returns (bool success) {
        if (!sales[_address]) {
            sales[_address] = true;
            success = true;
        }
    }

    /**
     * @dev remove sale smart contract address
     * @param _address address of sale smart contract
     * @return true if the address was added, false if the address was already
     */
    function removeSaleAddress(address _address) onlyOwnerOrCoOwner public returns (bool success) {
        if (sales[_address]) {
            sales[_address] = false;
            success = true;
        }
    }

    /**
     * @dev add an address to the whitelist
     * @param _address address for adding to whitelist
     * @return true if the address was added to the whitelist, false if the address was already in the whitelist
     */
    function addAddressToWhitelist(address _address) onlyOwnerOrCoOwner public returns (bool success) {
        if (!whitelist[_address]) {
            whitelist[_address] = true;
            success = true;
        }
    }

    /**
     * @dev add addresses to the whitelist
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
    function setStop() public onlyOwnerOrCoOwner {
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
            if (coOwner[coOwnerList[j]]) {
                unsold = unsold.add(balances[coOwnerList[j]]);
            }
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
    function transfer(address _to, uint _value) public checkAML(msg.sender, _to, _value) returns (bool) {
        if (BasicToken.transfer(_to, _value)) {
            _addTransferAddress(_to);
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
    onlySale
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
     * @dev used for transfer bonus tokens after stopping ICO
     * @param _recipients list of recipients
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
            if (bonus_transferred_recipients[_recipients[i]] == false) {
                bonus_transferred_recipients[_recipients[i]] = transfer(_recipients[i], _amount[i]);
                total = total.add(_amount[i]);
            }
        }
        totalBonusToken = totalBonusToken.add(total);
        noBonusTokenRecipients = noBonusTokenRecipients.add(len);
    }

    /**
     * @dev Transfers the current balance to the owner and terminates the contract.
    */
    function destroy() onlyOwner isEnded public {
        selfdestruct(owner());
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

        transferredIndex = i;
    }

    /**
     * @dev Set transfer addresses
     * @param _address The address of investor
    */
    function _addTransferAddress(address _address) internal {
        //owners/sales or already added, no need to add to list
        bool notAddToList = isValidOwner(_address) || sales[_address] || (isInvestorAddresses[_address]);
        if (!notAddToList) {
            transferAddresses.push(_address);
            isInvestorAddresses[_address] = true;
        }
    }
}
