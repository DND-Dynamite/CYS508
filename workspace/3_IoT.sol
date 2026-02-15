// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IoTMarketplace {
    struct Device {
        uint id;
        string deviceType;
        uint price;
        bool isActive;
        address owner;
    }

    // Mapping to store device details [cite: 32]
    mapping(uint => Device) public devices; 
    // Mapping to store device IDs owned by a user [cite: 33]
    mapping(address => uint[]) public userDevices; 
    // Mapping to track access status 
    mapping(address => mapping(uint => bool)) public hasAccess;

    // Register a new IoT device with ID, type, and price [cite: 27, 28]
    function registerDevice(uint _id, string memory _type, uint _price) public {
        // Store device info, mark as active, and save owner address [cite: 29, 30]
        devices[_id] = Device(_id, _type, _price, true, msg.sender); 
        userDevices[msg.sender].push(_id);
    }

    // Function to retrieve specific device information [cite: 37]
    function getDeviceData(uint _id) public view returns (string memory, uint, bool) {
        Device storage d = devices[_id];
        return (d.deviceType, d.price, d.isActive); 
    }

    // Purchase access to device data [cite: 38]
    function buyDataAccess(uint _id) public payable {
        Device storage d = devices[_id];
        require(d.isActive, "Device not active");
        // Check if buyer balance is sufficient [cite: 39]
        require(msg.value >= d.price, "Insufficient funds"); 

        // Update access status BEFORE transfer (Security Best Practice) 
        hasAccess[msg.sender][_id] = true; 

        // FIXED: Transfer payment to device owner using .call [cite: 40]
        (bool success, ) = payable(d.owner).call{value: d.price}("");
        require(success, "Transfer to owner failed");

        // Refund excess amount if overpaid [cite: 41]
        if (msg.value > d.price) {
            uint refundAmount = msg.value - d.price;
            (bool refundSuccess, ) = payable(msg.sender).call{value: refundAmount}("");
            require(refundSuccess, "Refund failed");
        }
    }

    // Deactivate a device so data is no longer for sale [cite: 43]
    function deactivateDevice(uint _id) public {
        // Only the device owner can execute deactivation [cite: 44]
        require(msg.sender == devices[_id].owner, "Only owner can deactivate"); 
        devices[_id].isActive = false; 
    }
}