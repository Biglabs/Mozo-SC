pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/token/ERC20/ERC20.sol";
import "../../mozo/contracts/Owner.sol";
/**
 * @title Utility interfaces
 * @author Biglabs Pte. Ltd.
 * @dev Standard ERC20 smart contract with owner
*/

contract OwnerStandardERC20 is ERC20, Owner {
}
