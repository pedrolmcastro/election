// SPDX-License-Identifier: MIT
// Inspired by https://solidity-by-example.org/app/iterable-mapping/

pragma solidity ^0.8.20;


library Candidates {
    struct Information {
        uint age;
        string proposal;
    }

    // Iterable mapping from candidate name to information
    struct Map {
        string[] _keys;
        mapping(string => uint) _indices;
        mapping(string => bool) _contains;
        mapping(string => Information) _values;
    }


    event Removed(string indexed key);
    event Added(string indexed key, Information value);
    event Updated(string indexed key, Information old, Information current);


    error InvalidKey(string key);
    error DuplicateKey(string key);
    error InvalidIndex(uint index);


    function contains(Map storage map, string memory key) public view returns(bool) {
        return map._contains[key];
    }

    function length(Map storage map) public view returns(uint) {
        return map._keys.length;
    }


    function get(Map storage map, string memory key) public view returns(Information storage) {
        if (!contains(map, key)) {
            revert InvalidKey(key);
        }

        return map._values[key];
    }

    function at(Map storage map, uint index) public view returns(string storage, Information storage) {
        if (index >= length(map)) {
            revert InvalidIndex(index);
        }

        string storage key = map._keys[index];
        return (key, get(map, key));
    }


    function update(Map storage map, string memory key, Information memory value) public {
        if (!contains(map, key)) {
            revert InvalidKey(key);
        }

        Information storage old = get(map, key);
        map._values[key] = value;

        emit Updated(key, old, value);
    }

    function add(Map storage map, string memory key, Information memory value) public {
        if (contains(map, key)) {
            revert DuplicateKey(key);
        }

        map._indices[key] = length(map);
        map._keys.push(key);

        map._values[key] = value;
        map._contains[key] = true;

        emit Added(key, value);
    }

    function set(Map storage map, string memory key, Information memory value) public {
        contains(map, key) ? update(map, key, value) : add(map, key, value);
    }


    function remove(Map storage map, string memory key) public {
        if (!contains(map, key)) {
            revert InvalidKey(key);
        }

        uint index = map._indices[key];
        (string storage last,) = at(map, length(map) - 1);

        // Swap the last key to replace the removed one
        map._indices[last] = index;
        map._keys[index] = last;

        map._keys.pop();
        delete map._values[key];
        delete map._indices[key];
        delete map._contains[key];

        emit Removed(key);
    }

    function discard(Map storage map, string memory key) public returns(bool) {
        if (contains(map, key)) {
            remove(map, key);
            return true;
        }

        return false;
    }
}
