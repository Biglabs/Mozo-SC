pragma solidity 0.4.23;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./Closable.sol";
import "./ChainOwner.sol";
import "./ICO.sol";

/**
 * @title Sale smart contract
 * @author Biglabs Pte. Ltd.
 * @dev : ICO Sale based smart contract
 */
 
contract Sale is ChainOwner, Closable {
    using SafeMath for uint;

    //Sale Token ref
    ICO public smzoToken;
    
    //Sold tokens
    uint public sold;

    /**
     * @dev Sale constructor
     * @param _ico ICO smart contract
    */
    function Sale(ICO _ico) internal ChainOwner(_ico) onlyOwner() {
        smzoToken = _ico;
    }

    /**
    * @dev Fall back function ~ buyToken
    */
    function() public payable {
        buyToken();
    }

    /**
    * @dev Get ICO smart contract
    */
    function ico() public view returns (ICO) {
        return smzoToken;
    }

    /**
    * @dev Get the number of remain tokens
    */
    function noTokens() public view returns (uint) {
        return smzoToken.balanceOf(this);
    }

    /**
    * @dev Investor buy Sale Token use ETH
    */
    function buyToken() public payable returns (bool) {
        uint tokenToFund = _calculateToken();

        _checkNoToken(tokenToFund);
        
        //collect eth
        _collectMoney();

        bool ret = smzoToken.transferByEth(msg.sender, msg.value, tokenToFund);
        if (ret) {
            sold = sold.add(tokenToFund);
        }
        return ret;
    }

    /**
    * @dev Get number of sold tokens
    */
    function getSoldToken() public view returns (uint) {
        return sold;
    }


    /**
     * @dev Owner withdraw all accidentally Eth
     * 
    */
    function withdraw() public onlyOwner {
        _widthdraw();
    }
    
    /**
     * @dev Owner get all unsold tokens back
     * 
    */
    function returnToken() public onlyOwner notClosed {
        _returnToken(noTokens().sub(_holdTokens()));
    }

    /**
    * @dev Check whether tokens is enough for buying
    */
    function _checkNoToken(uint _value) internal view {
        require(_value <= noTokens());
    }

    /**
    * @dev Calculate number of tokens based on wei contribution
    */
    function _calculateToken() internal view returns (uint) {
        return ico().calculateNoToken(msg.value);
    }

    /**
    * @dev Collect money (send eth to owner wallet)
    */
    function _collectMoney() internal {
        return owner().transfer(msg.value);
    }
    
    function _widthdraw() internal {
        //transfer accidentally eth in this contract if any to owner wallet
        if (address(this).balance > 0) {
            owner().transfer(address(this).balance);
        }
    }
    
    function _returnToken(uint no) internal {
        require(no > 0);
        ico().transfer(owner(), no);
    }
    
    /**
     * @dev Calculate number of tokens to be held
    */
    function _holdTokens() internal view returns(uint) {
        return 0;
    }

    function _bonusProcess() internal {
        //default 
        //Noop
    }

    /**
    * @dev Release the contract
    */
    function _release() internal {
        _widthdraw();
        _bonusProcess();
        _returnToken(noTokens());
        close();
    }
}