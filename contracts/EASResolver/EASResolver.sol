// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import { SchemaResolver } from "./SchemaResolver.sol";

import { IEAS, Attestation } from "./IEAS.sol";

contract RecipientResolver is SchemaResolver {
    mapping (address => bool) private whitelisted;
    address private _owner;

    constructor(IEAS eas) SchemaResolver(eas) {
       _owner = msg.sender;
    }

    /**
    * Check if the attester can attest
    */
    function canAttest(address addr) public view returns (bool){
        return whitelisted[addr];
    }

    /**
    *  Add to whitelist
    */
    function enlist(address addr) public virtual {
      require(msg.sender == _owner, "Address not allowed.");
      require(!canAttest(addr), "Address already whitelisted.");
      whitelisted[addr] = true;
    }

    /**
     * Remove the delegate from the whitelist
     */
    function delist(address addr) public {
        require(msg.sender == _owner, "Address not allowed.");
        whitelisted[addr] = false;
    }

    /**
     * This is an bottom up event, called from the attest contract
     */
    function onAttest(Attestation calldata attestation, uint256 /*value*/) internal view override returns (bool) {
        return canAttest(attestation.attester);
    }

    /**
     * This is an bottom up event, called from the attest contract
     */
    function onRevoke(Attestation calldata /*attestation*/, uint256 /*value*/) internal pure override returns (bool) {
        return true;
    }
}