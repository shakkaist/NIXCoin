pragma solidity ^0.4.23;

import  "./Ownable.sol";
import  "./StandardToken.sol";


contract nix is Ownable, StandardToken {


    string public constant symbol =  "NIX";
    string public constantname =  "NIX";
    uint256 public constant decimals = 18;
    
    uint256 reserveTokensLockTime;
    address reserveTokenAddress;


    address public depositWalletAddress;
    uint256 public weiRaised;
    using SafeMath for uint256;
    
    constructor() public {
        owner = msg.sender;
        depositWalletAddress = owner;
        totalSupply_ = 500000000 ether; // as ether is only because we need to multiply tokens with 10** decimals and dicmals is 18
        balances[owner] = 150000000 ether;
        emit Transfer(address(0),owner, balances[owner]);

        reserveTokensLockTime = 182 days; //year lock time
        reserveTokenAddress = 0xf6c5dE9E1a6b36ABA36c6E6e86d500BcBA9CeC96; //TODO change address before deploy
        balances[reserveTokenAddress] = 350000000 ether;
        emit Transfer(address(0),reserveTokenAddress, balances[reserveTokenAddress]);
    }


    //This buy event is used only for ico duration 
    event Buy(address _from, uint256 _ethInWei, string userId);
    function buy(string userId)public payable {
        require(msg.value > 0);
        require(msg.sender != address(0));
        weiRaised += msg.value;
        forwardFunds();
        emit Buy(msg.sender, msg.value, userId);
    } //end of buy

     /**
      * @dev Determines how ETH is stored/forwarded on purchases.
    */
    function forwardFunds()internal {
        depositWalletAddress.transfer(msg.value);
    }


    function changeDepositWalletAddress(address newDepositWalletAddr)public onlyOwner {
        require(newDepositWalletAddr != 0);
        depositWalletAddress = newDepositWalletAddr;
    }

    function transfer(address _to, uint256 _value) public reserveTokenLock returns (bool) {
        super.transfer(_to,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public reserveTokenLock returns (bool){
        super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public reserveTokenLock returns (bool) {
        super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public reserveTokenLock returns (bool) {
        super.increaseApproval(_spender, _addedValue);
    }


    modifier reserveTokenLock () {
        if(msg.sender == reserveTokenAddress){
            require(block.timestamp > reserveTokensLockTime);
            _;
        }
        else{
            _;
        }
    }
}
