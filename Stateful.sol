// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import "Owned.sol";


abstract contract Stateful is Owned {
    enum State {
        PENDING,
        STARTED,
        FINISHED
    }


    State private _state = State.PENDING;


    event Started();
    event Finished();


    error InvalidState(State state);


    modifier onPending {
        _check(State.PENDING);
        _;
    }

    modifier onStarted {
        _check(State.STARTED);
        _;
    }

    modifier onFinished {
        _check(State.FINISHED);
        _;
    }


    function start() onlyOwner onPending public {
        _state = State.STARTED;
        emit Started();
    }

    function finish() onlyOwner onStarted public {
        _state = State.FINISHED;
        emit Finished();
    }


    function _check(State desired) view private {
        if (_state != desired) {
            revert InvalidState(_state);
        }
    }
}
