// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {SchemaResolver} from "@ethereum-attestation-service/eas-contracts/contracts/resolver/SchemaResolver.sol";
import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

contract NFTUpdatingResolver is SchemaResolver {
    // repoName => address = 1
    mapping(string => mapping(address => uint256)) public prCount;
    address public _owner;

    constructor(IEAS eas) SchemaResolver(eas) {
        _owner = msg.sender;
    }

    /**
     * This is an bottom up event, called from the attest contract
     */
    function onAttest(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal view override returns (bool) {
      //XXX You need to decode attestation data
      //prCount[attestation.repoName][address] += 1;
      return true;
    }

    /**
     * This is an bottom up event, called from the attest contract
     */
    function onRevoke(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal view override returns (bool) {
      //XXX You need to decode attestation data
      //prCount[attestation.repoName][address] -= 1;
      return true;
    }

    function getPRCount(string memory repoName, address developer) public returns (uint256) {
      return prCount[repoName][developer];
    }
}
