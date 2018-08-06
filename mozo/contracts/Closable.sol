pragma solidity 0.4.23;

/**
 * @title Utility smart contracts
 * @author Biglabs Pte. Ltd.
 * @dev Closable smart contract
 */
 
contract Closable {
    //indicate whether closed or not
    bool public isClosed = false;

    modifier notClosed() {
        require(!isClosed);
        _;
    }

    modifier requireClosed() {
        require(isClosed);
        _;
    }

    /**
    * @dev Close this smart contract. Just turn on the flag indicates that smart contract is closed
    */
    function _close() internal {
        isClosed = true;
    }
}