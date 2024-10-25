//SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract DelegateOracle {
    address private immutable _admin;
    mapping(address => bool) private _delegateStatus;

    /* inputs could look like this "v:1.1;ov:50;sv:80;fs:33;ts:80"
       v - Version to determine parsing logic
       ov - Onchain voting pct
       sv - Snapshot voting pct
       fs - forum score
       ts - Total score
    */
    event DelegateStatusChanged(address indexed delegate, bool isActive, string inputs);

    constructor(address admin) {
        _admin = admin;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Only admin can perform this action");
        _;
    }

    // We will always set the status if it has changed
    // We are thinking of optionally setting the status 
    function setDelegateStatus(address delegate, bool isActive, string memory inputs) external onlyAdmin {
        _delegateStatus[delegate] = isActive;
        emit DelegateStatusChanged(delegate, isActive, inputs);
    }

    function isDelegateActive(address delegate) external view returns (bool) {
        return _delegateStatus[delegate];
    }
}
