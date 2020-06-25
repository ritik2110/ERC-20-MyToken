pragma solidity ^0.6.9;

//@ import statement for the template to this contract. 
import "ERC20Interface.sol";
 
contract ERC20Token
{
    //@ Owner of this contract;
    //@ Initiale supply of token is held by the admin. 
    //@ Once token is added to the system anyone with required contraints can transact.
    address payable admin;
    
    //@ Attribute of the token.
    //@ Decimal is the minimum division of token allowed like 1 ETH = 10**18 wei.
    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint256 decimal;
    uint256 price;
    
    //@ Event logging for web interface and better auditing. 
    event Transfer (address payable indexed _to,uint256 indexed _value);
    event Approve (address payable indexed _from, address payable indexed _to, uint256 indexed _value);
    event TransferFrom (address payable indexed _owner,address payable indexed _from, address payable indexed _to, uint256 _amount);
    event BuyToken (address payable indexed _from, address indexed _to,uint256 indexed _numToken);
    
    //@ Maps the ethereum address to the number of tokens in holding.
    mapping (address => uint256) public balances;
    
    //@ If owner allows some other ethereum address to spend the allocated amount of tokens.
    //@ The third party allowed account can only spend the amount of value thats is allocated to it once.
    mapping (address => mapping (address => uint256)) public allowance;
    
    //@ Setting up of attributes of the token.
    //@ For this contract price of one token is set to 1 ether.
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
    
    //@ commeneted out but can be used in future.
    // modifier onlyAdmin () 
    // {
    //     require (msg.sender == admin, "Not Authoried");
    //     _;
    // }
    
    // Checks for the value entered is valid or not.
    modifier validAmount (uint256 _value)
    {
        require (_value > 0, "Invalid amount");
        _;
    }
    
    //@ Can be used for low level transactions.
    //@ The number of token can be changed form 5 to any positive integer.
    fallback () external payable 
    {
        buyToken (admin, 5 ** decimal);
    }
     
     //@ Usual transfer function transfer tokens from one accont to another.
    function transfer (address payable _to, uint256 _value) public 
    validAmount (_value)
    returns (bool success)
    {
        require (balances[msg.sender] > _value, "Insuffcient balance");
        
        _transfer (msg.sender, _to, _value);    
       
        emit Transfer (_to, _value);
       
        return true;
    }
    
    //@ This fuction give approvement for allowance of a certain value to be spend by a third party address.
    //@ Like a wallet put some value in it and number of token allocated in it is used by address to it the tokens are allocated.
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
    
    //@ This function is specific to allowance mapping only the one's allocated with certain amount of token 
    //@ can access this function
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
    
    //@ Internal function used inside this contract can't be accessed outside.
    function _transfer (address _from, address _to, uint256 _value) internal validAmount (_value){
        
        require (_to != address(0), "Address not Exist");
        require (balances[_from] > _value, "Insufficent balance");
        
        balances[_to] += _value;
        balances[_from] -= _value;
    }
    
    //@ This function is payable.
    //@ Users can directly buy token from anyone with the valid amount of token.
    //@ This function accepts ether for tokens.
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

    //@ Can buy 5 tokens at a time directly from a wallet.
    //@ Low level interraction with the smart contract.
    receive () external payable 
    {
        buyToken (admin, 5 ** decimal);
    }
}
