pragma solidity 0.4.23;

import "../../open-zeppelin/contracts/token/ERC20/ERC20Basic.sol";
import "./Owner.sol";
/**
 * @title Utility interfaces
 * @author Biglabs Pte. Ltd.
 * @dev ERC20 smart contract with owner
*/

contract OwnerERC20 is ERC20Basic, Owner {
}
