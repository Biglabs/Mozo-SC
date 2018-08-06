pragma solidity 0.4.23;

import "./ChainCoOwner.sol";
import "./MozoToken.sol";

contract MozoTokenDistribution is ChainCoOwner {

    MozoToken public mozoToken;

    modifier onlyOwnerOrCoOwner() {
        require(isValidOwner(msg.sender));
        _;
    }

    constructor(MozoToken _mozoToken, address[] _coOwners) public ChainCoOwner(_mozoToken, _coOwners) {
        mozoToken = MozoToken(_mozoToken);
    }

    function airdrop(address[] _recipients, uint[] _amounts) public onlyOwnerOrCoOwner {
        uint length = _recipients.length;
        for (uint i = 0; i < length; i++) {
            mozoToken.transfer(_recipients[i], _amounts[i]);
        }
    }
}