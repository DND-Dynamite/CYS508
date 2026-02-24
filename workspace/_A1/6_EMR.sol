// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HealthcareEMR {
    struct Patient {
        uint id;
        bytes32 nameHash;
        string recordHash;
        bool isActive;
        address hospital;
        uint visitCount;
    }

    mapping(address => Patient) public patients;
    mapping(address => mapping(address => bool)) public authorizedDoctors; // [cite: 90]

    function registerPatient(uint _id, bytes32 _nameHash, string memory _recordHash) public {
        patients[msg.sender] = Patient(_id, _nameHash, _recordHash, true, msg.sender, 0); // [cite: 85, 86, 87, 88]
    }

    function grantAccess(address _doctor) public {
        authorizedDoctors[msg.sender][_doctor] = true; // [cite: 91, 92]
    }

    function updateRecord(address _patient, string memory _newRecordHash) public {
        require(authorizedDoctors[_patient][msg.sender], "Not authorized"); // [cite: 94]
        patients[_patient].recordHash = _newRecordHash;
        patients[_patient].visitCount++; // [cite: 98, 99]
        // Updated timestamp via block.timestamp [cite: 95]
    }

    function viewRecord(address _patient) public view returns (string memory) {
        require(msg.sender == _patient || authorizedDoctors[_patient][msg.sender], "Access denied"); // [cite: 97]
        return patients[_patient].recordHash; // [cite: 96]
    }
}