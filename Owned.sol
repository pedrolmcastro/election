// SPDX-License-Identifier: MIT
// Inspired by https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

pragma solidity ^0.8.20;


abstract contract Owned {
    address private _owner;
    address constant private _NULL = address(0);


    event OwnershipTransfer(address indexed old, address indexed current);


    error InvalidOwner(address owner);
    error Unauthorized(address sender);


    modifier onlyOwner {
        if (owner() != msg.sender) {
            revert Unauthorized(msg.sender);
        }

        _;
    }


    constructor(address initial) {
        if (initial == _NULL) {
            revert InvalidOwner(initial);
        }

        _owner = initial;
    }


    function owner() view public returns(address) {
        return _owner;
    }

    function transferOwnership(address to) onlyOwner public {
        if (to == _NULL) {
            revert InvalidOwner(to);
        }

        address old = _owner;
        _owner = to;

        emit OwnershipTransfer(old, to);
    }
}
