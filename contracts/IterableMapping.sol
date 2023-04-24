// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FamilyList {
    mapping(string => uint256) family;
    mapping(string => bool) isIncluded;
    mapping(uint256 => bool) isIncludedAge;
    string[] public names;

    function addPerson(string memory _name, uint256 _age) public {
        family[_name] = _age;

        if (!isIncluded[_name]) {
            isIncluded[_name] = true;
            names.push(_name);
        }
    }

    function numberOfPersons() public view returns (uint256) {
        return names.length;
    }

    function getAgeByIndex(uint256 _index) public view returns (uint256) {
        string memory name = names[_index];
        return family[name];
    }

    function getAllAges() public view returns (uint256[] memory) {
        uint256[] memory allAges = new uint256[](names.length);

        for (uint256 i = 0; i < names.length; i++) {
            allAges[i] = family[names[i]];
        }
        return allAges;
    }
}
