pragma solidity ^0.6.9;

import "ERC20Interface.sol";

contract MyToken 
{
    address payable admin;
    
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 decimal;
    uint256 price;
    
    
    event Transfer (address payable indexed _to,uint256 indexed _value);
    event Approve (address payable indexed _from, address payable indexed _to, uint256 indexed _value);
    event TransferFrom (address payable indexed _owner,address payable indexed _from, address payable indexed _to, uint256 _amount);
    event BuyToken (address payable indexed _from, address indexed _to,uint256 indexed _numToken);
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowance;
    
    constructor (string memory _name, string memory _symbol, uint256 _totalSupply, uint256 _decimal) public 
    {
        admin = msg.sender;
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupply;
        decimal = _decimal;
        balances[admin] = (totalSupply) * (10 ** decimal);
        price = 1 ether;
    }
    
    // modifier onlyAdmin () 
    // {
    //     require (msg.sender == admin, "Not Authoried");
    //     _;
    // }
    
    modifier validAmount (uint256 _value)
    {
        require (_value > 0, "Invalid amount");
        _;
    }
    
    fallback () external payable 
    {
        buyToken (admin, 5 ** decimal);
    }
        
    function transfer (address payable _to, uint256 _value) public 
    validAmount (_value)
    returns (bool success)
    {
        require (balances[msg.sender] > _value, "Insuffcient balance");
        
        _transfer (msg.sender, _to, _value);    
       
        emit Transfer (_to, _value);
       
        return true;
    }
    
    function approve (address payable _spender, uint256 _value) public 
    validAmount (_value)
    returns (bool success)
    {
        require (_spender != address(0), "Address not Exist");
        require (_value > 0, "Invalid amount");
        require (balances[msg.sender] > 0, "Insuffcient balance");
        
        allowance[_spender][msg.sender] = _value;
        
        emit Approve (msg.sender, _spender, _value);
        
        return true;
    }
    
    function transferFrom (address payable _from, address payable _to, uint256 _amount) public 
    validAmount (_amount)
    returns (bool success)
    {
        require (allowance[msg.sender][_from] >= _amount);
        require (balances[_from] > _amount, "The owner has Insufficent balance");
        
        allowance[msg.sender][_from] -= _amount;
        balances[_from] -=_amount;
        balances[_to] += _amount;
        
        emit TransferFrom (_from, msg.sender, _to, _amount);
        
        return true;
    }
    
    function _transfer (address _from, address _to, uint256 _value) internal validAmount (_value){
        
        require (_to != address(0), "Address not Exist");
        require (balances[_from] > _value, "Insufficent balance");
        
        balances[_to] += _value;
        balances[_from] -= _value;
    }
    
    function buyToken (address payable _from, uint256 _numToken) public 
    payable 
    validAmount(_numToken) 
    returns (bool success)
    {
        require (msg.value == (_numToken*price), "Invalid amount");
        require(balances[_from] > _numToken, "Out of Tokens");
        
        _transfer(_from, msg.sender, _numToken);
        
        emit BuyToken (_from, msg.sender, _numToken);
        
        return true;
    }

    receive () external payable 
    {
        buyToken (admin, 5 ** decimal);
    }
}