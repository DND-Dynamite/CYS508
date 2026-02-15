// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BankingSystem {
    // Mapping between EOA address and corresponding balance [cite: 18]
    mapping(address => uint) public balanceLedger; 
    // Mapping index values for each EOA address [cite: 19]
    mapping(uint => address) public addressIndex; 
    uint public userCount;

    // Handle deposits and update mappings [cite: 20]
    function deposit() public payable {
        if (balanceLedger[msg.sender] == 0) {
            userCount++;
            addressIndex[userCount] = msg.sender; 
        }
        balanceLedger[msg.sender] += msg.value;
    }

    // Check the caller's EOA balance [cite: 21]
    function getBalance() public view returns (uint) {
        return balanceLedger[msg.sender]; 
    }

    // Withdraw funds using the modern .call method 
    function withdraw(uint _amount) public {
        require(balanceLedger[msg.sender] >= _amount, "Insufficient funds"); 
        
        // Update balance before the external call (Best Practice)
        balanceLedger[msg.sender] -= _amount;

        // FIXED: Using .call instead of .transfer to resolve deprecation 
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed");
    }

    // Update ledger if sender has sufficient balance for transfer 
    function transfer(address _to, uint _amount) public {
        require(balanceLedger[msg.sender] >= _amount, "Insufficient funds"); 
        balanceLedger[msg.sender] -= _amount;
        balanceLedger[_to] += _amount;
    }

    // Find account address of the user with the minimum amount 
    function minDeposit() public view returns (address) {
        if (userCount == 0) return address(0);
        
        address minUser = addressIndex[1];
        for (uint i = 2; i <= userCount; i++) {
            if (balanceLedger[addressIndex[i]] < balanceLedger[minUser]) {
                minUser = addressIndex[i];
            }
        }
        return minUser;
    }
}