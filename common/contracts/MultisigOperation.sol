pragma solidity ^0.4.24;

import "../../open-zeppelin/contracts/math/SafeMath.sol";
import "./ERC20Exchangable.sol";
import "./CheckingAddress.sol";

/**
 * @title Multisig operation smart contract
 * @notice Should transfer tokens to this smart contract
 * @author Biglabs Pte. Ltd.
 * @dev : Multisig operation smart contract - use for Buy/Sell tokens
 */
 
contract MultisigOperation is CheckingAddress{
    using SafeMath for uint;

    /**
     * @dev Sold info
    */
    struct SoldInfo {
        address from;
        address to; 
        uint value;
        bool fee;
        mapping(address => bool) signed;
        uint8 count;
    }    

    //hold signed map
    mapping(bytes32 => SoldInfo) internal soldMap;
    
    //minimum required signatures
    uint8 internal minRequiredSign = 1;

    //required signatures    
    uint8 internal requiredSign = 2;
    
    ERC20Exchangable exchangable;
    
	/**
     * @dev Only owner
    */
    modifier onlyOwner() {
        require(msg.sender == exchangable.getOwner());
        _;
    }

	/**
     * @dev Only operation wallet
    */
    modifier onlyOperation() {
        require(isAddress(msg.sender));
        _;
    }
    
	/**
     * @dev Check before sold
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
    */
    modifier checkSold(bytes32 _hash, address _from, address _to, uint _value, bool _isFee) {
        require(noTokens() >= _value);
        SoldInfo storage s = soldMap[_hash];
        //first signature
        if( s.count == 0) {
            s.from = _from;
            s.to = _to;
            s.value = _value;
            s.fee = _isFee;
            s.signed[msg.sender] = true;
            s.count = 1;
        } else {
            if(s.signed[msg.sender] == false && _from == s.from && _to == s.to && _value == s.value && s.fee == _isFee) {
                s.signed[msg.sender] = true;
                s.count = s.count + 1;
            }
        }
        if(s.count >= requiredSign) {
            _;
        }
    }

    /**
     * @dev Multisig operation constructor
     * @param _ex exchangable treasury smart contract
     * @param _operationWallets List of operation wallets
    */
    constructor(ERC20Exchangable _ex, address[] _operationWallets, uint8 _minRequiredSign) public CheckingAddress(_operationWallets) {
        require(minRequiredSign >= 1);
        exchangable = _ex;
        minRequiredSign = _minRequiredSign;
    }

    function noTokens() public view returns(uint) {
        return exchangable.getERC20().balanceOf(this);
    }
    
    /**
     * @dev change number of required signatures
     * @param _requiredSign number of required signatures
    */
    function changeRequiredSign(uint8 _requiredSign) public onlyOwner {
        require(_requiredSign >= minRequiredSign);
        requiredSign = _requiredSign;    
    }

    /**
     * @dev Operation sign and send transaction until enough number of signatures
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
    */
    function sold(bytes32 _hash, address _from, address _to, uint _value) public onlyOperation checkSold(_hash, _from, _to, _value, false) {
        exchangable.sold(_hash, _from, _to, _value);
    }
    
    /**
     * @dev called by Bridge when a bought event occurs, it will transfer ERC20 tokens to receiver address
     * @param _hash Transaction hash in other blockchain
     * @param _from bought address 
     * @param _to The received address 
     * @param _value Number of tokens
     */
    function soldWithFee(bytes32 _hash, address _from, address _to, uint _value) public onlyOperation checkSold(_hash, _from, _to, _value, true) {
        exchangable.soldWithFee(_hash, _from, _to, _value);
    }
}