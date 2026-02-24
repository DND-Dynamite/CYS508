// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SRMLibraryToken {
    // a) Token Identity
    string public name = "SRM LIBRARY Token";
    string public symbol = "SRMLib";
    uint8 public decimals = 18;

    // b) Supply and Balances
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    
    // f) Allowances
    mapping(address => mapping(address => uint256)) public allowance;

    // h) Transfer Event
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // i) Approval Event
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor() {
        // b) Initial Supply: 50,000 tokens (multiplied by 10^18 for decimals)
        totalSupply = 50000 * 10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    /**
     * d) Transfer tokens to a specified address
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * f) Allow _spender to withdraw from your account up to _value
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * e) Send _value tokens from _from to _to using allowance
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Insufficient balance");
        require(_value <= allowance[_from][msg.sender], "Allowance exceeded");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * c) Get account balance (Explicitly defined as requested)
     */
    function getBalance(address _owner) public view returns (uint256 balance) {
        return balanceOf[_owner];
    }
}