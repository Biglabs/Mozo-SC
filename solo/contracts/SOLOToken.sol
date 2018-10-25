pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/token/ERC20/StandardToken.sol";
import "../../mozo/contracts/OwnerERC20.sol";
import "../../common/contracts/ERC20Exchangable.sol";
import "../../common/contracts/Mintable.sol";
import "../../common/contracts/Burnable.sol";

/**
 * @title SOLO tokens
 * @author Biglabs Pte. Ltd.
 */

contract SOLOToken is StandardToken, OwnerERC20, Mintable, Burnable {
    //token name
    string public constant name = "SOLO Token";

    //token symbol
    string public constant symbol = "SOLO";

    //token decimals
    uint8 public constant decimals = 2;
    
    //contract type
    string public constant contractType = "SOLO Token";

    //owner of contract
    address public owner_;
    ERC20Exchangable public treasury;

    modifier onlyOwner() {
        require(msg.sender == owner_);
        _;
    }

    modifier onlyMinter() {
        require(msg.sender == address(treasury));
        _;
    }

    /**
     * @dev Constructor
    */
    constructor() public {
        owner_ = msg.sender;
        // constructor
        totalSupply_ = 0;
        //this is mintable and burnable tokens
        //so it will not hold any tokens
    }
    
    /**
     * @dev Set treasury (minter)
     * @param _address Address of treasury (minter)
    */
    function setTreasury(address _address) public onlyOwner {
        treasury = ERC20Exchangable(_address);
    }
    
    /**
     * @dev Mint tokens
     * @param _value Number of tokens
    */
    function mint(uint _value) public onlyMinter {
        totalSupply_ = totalSupply_.add(_value);
        balances[msg.sender] = balances[msg.sender].add(_value);
        emit Mint(msg.sender, _value);
    }
    
    

    /**
    * @dev Get smart contract's owner
    */
    function owner() public view returns (address) {
        return owner_;
    }

    /**
     * @dev Check valid owner
     * @param _address Address to check
    */
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
    function soldSOLO(address _to, uint _value) public returns(bool) {
        require(_to != address(0));
        _burn(_value);

        treasury.autoBuyERC20(msg.sender, _to, _value);
        return true;
    }

    function _burn(uint _value) private {
        require(_value <= balances[msg.sender]);
        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burned(msg.sender, _value);
    }
}
