pragma solidity 0.7.6;

contract MappingChallenge {
    bool public isComplete;
    uint256[] map;
    uint key = 0;
    
    /*  Original code will not compile in 0.6 solidity as you can no longer expand an array this way
    function set(uint256 key, uint256 value) public {
        // Expand dynamic array as needed
        if (map.length <= key) {
            map.length = key + 1;
        }
        map[key] = value;
    }
    */

    function set(uint value) public {
        map.push(value);
    }

    function get(uint _key) public view returns (uint256) {
        return map[_key];
    }
}
