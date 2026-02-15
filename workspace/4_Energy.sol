// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EnergyTrading {
    struct Producer {
        uint energyAvailable; // kWh
        uint pricePerUnit;    //
        bool isActive;        //
        address producerAddress; //
    }

    // Energy Ledger Mappings
    mapping(address => Producer) public producers;
    mapping(address => uint) public energyBalance; // For tracking kWh
    mapping(address => uint) public energyCredits; //
    address[] public producerList;

    // Register Energy Producer
    function registerProducer(uint _units, uint _price) public {
        producers[msg.sender] = Producer(_units, _price, true, msg.sender);
        producerList.push(msg.sender);
    }

    // Buy Energy Function
    function buyEnergy(address _producer, uint _units) public payable {
        Producer storage p = producers[_producer];
        uint totalCost = _units * p.pricePerUnit;

        // Validations
        require(p.isActive, "Producer is not active");
        require(p.energyAvailable >= _units, "Insufficient energy units available");
        require(msg.value >= totalCost, "Insufficient payment balance");

        // 1. Update State (Effects) BEFORE external calls
        p.energyAvailable -= _units;
        energyBalance[msg.sender] += _units;

        // 2. Transfer Payment (Interactions)
        (bool success, ) = payable(_producer).call{value: totalCost}("");
        require(success, "Payment to producer failed");

        // 3. Refund excess amount
        if (msg.value > totalCost) {
            uint refund = msg.value - totalCost;
            (bool refundSuccess, ) = payable(msg.sender).call{value: refund}("");
            require(refundSuccess, "Refund failed");
        }
    }

    // Identify the producer selling maximum energy units
    function maxEnergySeller() public view returns (address) {
        if (producerList.length == 0) return address(0);
        
        address topSeller = producerList[0];
        for (uint i = 1; i < producerList.length; i++) {
            if (producers[producerList[i]].energyAvailable > producers[topSeller].energyAvailable) {
                topSeller = producerList[i];
            }
        }
        return topSeller;
    }
}