pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/token/ERC20/StandardToken.sol";
import "./OwnerERC20.sol";

/**
 * @title Mozo tokens
 * @author Biglabs Pte. Ltd.
 */

contract MozoToken is StandardToken, OwnerERC20 {
    //token name
    string public constant name = "Mozo Token";

    //token symbol
    string public constant symbol = "MOZO";

    //token symbol
    uint8 public constant decimals = 2;

    //owner of contract
    address public owner_;

    modifier onlyOwner() {
        require(msg.sender == owner_);
        _;
    }


    /**
     * @notice Should provide _totalSupply = No. tokens * 100
     * @param _totalSupply Number of suply tokens = No. tokens * decimals = No. tokens * 100
    */
    function MozoToken(uint256 _totalSupply) public {
        owner_ = msg.sender;
        // constructor
        totalSupply_ = _totalSupply;
        //assign all tokens to owner
        balances[msg.sender] = totalSupply_;
        emit Transfer(0x0, msg.sender, totalSupply_);
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
}
