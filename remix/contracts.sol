pragma solidity ^0.;

contract SrmContract {
    string name;
    int age;
    string id;

    function get() public view returns(string memory) {
        return id ;
    }

    // function set(string memory name) public {
    //     name = _value;
    // }

    function set(string memory _value) public {
        name = _value;
    }



}

