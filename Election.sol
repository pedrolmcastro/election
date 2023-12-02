// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;


import "Stateful.sol";
import "Candidates.sol";


contract Election is Stateful {
    uint public totalVotes;

    Candidates.Map private _candidates;
    mapping(string => uint) private _votes;
    mapping(address => bool) private _voted;


    event Vote(address voter, string candidate);


    error DuplicateVote(address voter);


    constructor() Owned(msg.sender) {}


    function registered(string memory candidate) view public returns(bool) {
        return Candidates.contains(_candidates, candidate);
    }

    function register(string calldata candidate, string calldata proposal, uint age) onlyOwner onPending external {
        Candidates.set(_candidates, candidate, Candidates.Information(age, proposal));
    }

    function unregister(string calldata candidate) onlyOwner onPending external {
        Candidates.remove(_candidates, candidate);
    }

    function information(string calldata candidate) view external returns(Candidates.Information memory) {
        return Candidates.get(_candidates, candidate);
    }


    function votes(string memory candidate) view public returns(uint) {
        if (!registered(candidate)) {
            revert Candidates.InvalidKey(candidate);
        }

        return _votes[candidate];
    }

    function voted(address voter) view public returns(bool) {
        return _voted[voter];
    }

    function vote(string calldata candidate) onStarted external {
        if (!registered(candidate)) {
            revert Candidates.InvalidKey(candidate);
        }

        if (voted(msg.sender)) {
            revert DuplicateVote(msg.sender);
        }

        totalVotes += 1;
        _votes[candidate] += 1;
        _voted[msg.sender] = true;

        emit Vote(msg.sender, candidate);
    }


    function winners() onFinished view external returns(string[] memory, uint) {
        // Find the maximum of votes and the number of candidates with that many votes
        uint max = 0;
        uint count = 0;

        for (uint i = 0; i < Candidates.length(_candidates); ++i) {
            (string storage candidate,) = Candidates.at(_candidates, i);
            uint value = votes(candidate);

            if (value > max) {
                max = value;
                count = 1;
            }
            else if (value == max) {
                count += 1;
            }
        }

        // Store the names of the candidates with maximum votes
        string[] memory winner = new string[](count);
        uint index = 0;

        for (uint i = 0; i < Candidates.length(_candidates); ++i) {
            (string storage candidate,) = Candidates.at(_candidates, i);

            if (votes(candidate) == max) {
                winner[index++] = candidate;
            }
        }

        return (winner, max);
    }
}
