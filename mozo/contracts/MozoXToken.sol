pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/token/ERC20/StandardToken.sol";
import "./OwnerERC20.sol";
import "../../common/contracts/ERC20Exchangable.sol";

/**
 * @title MozoX tokens
 * @author Biglabs Pte. Ltd.
 */

contract MozoXToken is StandardToken, OwnerERC20 {
    //token name
    string public constant name = "Mozo Extension Token";

    //token symbol
    string public constant symbol = "MOZOX";

    //token symbol
    uint8 public constant decimals = 2;

    //owner of contract
    address public owner_;
    ERC20Exchangable public treasury;

    modifier onlyOwner() {
        require(msg.sender == owner_);
        _;
    }


    /**
     * @notice Should provide _totalSupply = No. tokens * 100
    */
    constructor() public {
        owner_ = msg.sender;
        // constructor
        totalSupply_ = 50000000000000;
        //assign all tokens to owner
        balances[msg.sender] = totalSupply_;
        emit Transfer(0x0, msg.sender, totalSupply_);
    }
    
    /**
     * @dev Set treasury smart contract
     * @param _treasury Address of smart contract
    */
    function setTreasury(address _treasury) public onlyOwner {
        treasury = ERC20Exchangable(_treasury);
    }

    /**
    * @dev Get smart contract's owner
    */
    function owner() public view returns (address) {
        return owner_;
    }

    function isValidOwner(address _address) public view returns(bool) {
        if (_address == owner_) {
            return true;
        }
        return false;
    }  
    
    /**
    * @dev batch transferring token
    * @notice Sender should check whether he has enough tokens to be transferred
    * @param _recipients List of recipients addresses 
    * @param _values Values to be transferred
    */
    function batchTransfer(address[] _recipients, uint[] _values) public {
        require(_recipients.length == _values.length);
        uint length = _recipients.length;
        for (uint i = 0; i < length; i++) {
            transfer(_recipients[i], _values[i]);
        }
    }
    
    /**
     * @dev transfer token to Treasury smart contract and exchange to Mozo ERC20 tokens
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
    */
    function soldMozo(address _to, uint _value) public returns(bool) {
        require(_to != address(0));
        if(transfer(treasury, _value)) {
            treasury.autoBuyERC20(msg.sender, _to, _value);
            return true;
        }
        return false;
    }
}
