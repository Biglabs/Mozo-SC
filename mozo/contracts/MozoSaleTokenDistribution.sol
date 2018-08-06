pragma solidity 0.4.23;

import "./ChainCoOwner.sol";
import "./MozoSaleToken.sol";

contract MozoSaleTokenDistribution is ChainOwner {

    MozoSaleToken public smzoToken;

    modifier onlyOwnerOrCoOwner() {
        require(smzoToken.isValidOwner(msg.sender));
        _;
    }

    constructor(MozoSaleToken _smzoToken) public ChainOwner(_smzoToken) onlyOwner() {
        smzoToken = MozoSaleToken(_smzoToken);
    }

    function airdrop(address[] _recipients, uint[] _amounts) public onlyOwnerOrCoOwner {
        uint length = _recipients.length;
        for (uint i = 0; i < length; i++) {
            smzoToken.transfer(_recipients[i], _amounts[i]);
        }
    }
}
