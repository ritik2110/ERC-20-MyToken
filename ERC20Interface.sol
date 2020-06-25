pragma solidity ^0.6.8;

interface ERC20 {

    function transfer (address _to, uint256 _value) external returns (bool success);
    
    function approve (address _owner, address _spender, uint256 _value) external returns (bool success);

    function tranferFrom (address _owner, uint256 _value) external returns (bool success);
    
    function allowance (address _spender, uint256 _value) external returns (bool success);
    
}