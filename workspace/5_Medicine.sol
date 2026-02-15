// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PharmaSupplyChain {
    struct Batch {
        uint id;
        string name;
        uint quantity;
        string mfgDate;
        bool isDelivered;
        bool isRecalled;
        address currentCustodian;
        address manufacturer;
    }

    mapping(uint => Batch) public batches;
    uint[] public batchIds;

    function addMedicineBatch(uint _id, string memory _name, uint _qty, string memory _date) public {
        batches[_id] = Batch(_id, _name, _qty, _date, false, false, msg.sender, msg.sender); // [cite: 66, 67, 68, 69]
        batchIds.push(_id);
    }

    function transferOwnership(uint _id, address _newOwner) public {
        require(msg.sender == batches[_id].currentCustodian, "Not current custodian"); // [cite: 71]
        batches[_id].currentCustodian = _newOwner; // [cite: 72]
        // Timestamp recorded via block.timestamp if needed [cite: 73]
    }

    function recallBatch(uint _id) public {
        require(msg.sender == batches[_id].manufacturer, "Only manufacturer"); // [cite: 79]
        batches[_id].isRecalled = true; // [cite: 78]
    }

    function lowestStockHolder() public view returns (address) {
        address minRetailer = batches[batchIds[0]].currentCustodian;
        uint minQty = batches[batchIds[0]].quantity;

        for (uint i = 1; i < batchIds.length; i++) {
            if (batches[batchIds[i]].quantity < minQty) {
                minQty = batches[batchIds[i]].quantity;
                minRetailer = batches[batchIds[i]].currentCustodian; // [cite: 82]
            }
        }
        return minRetailer;
    }
}