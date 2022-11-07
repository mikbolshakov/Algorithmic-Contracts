// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FamList {
    mapping(string => uint) family;
    mapping(string => bool) isIncluded;
    mapping(uint => bool) isIncludedAge;
    string[] public names;

    function addPerson(string memory _name, uint _age) public {
        family[_name] = _age;

        if (!isIncluded[_name]) {
            isIncluded[_name] = true;
            names.push(_name);
        }
    }

    function numberOfPersons() public view returns (uint) {
        return names.length;
    }

    function getAgeByIndex(uint _index) public view returns (uint) {
        string memory name = names[_index];
        return family[name];
    }

    function getAllAges() public view returns (uint[] memory) {
        uint[] memory allAges = new uint[](names.length);

        for (uint i = 0; i < names.length; i++) {
            allAges[i] = family[names[i]];
        }
        return allAges;
    }
}
