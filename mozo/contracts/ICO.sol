pragma solidity 0.4.23;

import "./OwnerERC20.sol";

/**
 * @title Utility interfaces
 * @author Biglabs Pte. Ltd.
 * @dev ICO smart contract
 */
 
contract ICO is OwnerERC20 {
    //transfer tokens (use wei contribution information)
    function transferByEth(address _to, uint _weiAmount, uint _value) public returns (bool);

    //calculate no tokens
    function calculateNoToken(uint _weiAmount) public view returns(uint);
}