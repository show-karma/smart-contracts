// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {SchemaResolver} from "@ethereum-attestation-service/eas-contracts/contracts/resolver/SchemaResolver.sol";
import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

// errors
error NotOwner();

contract DevSchemaResolver is SchemaResolver {
    // username => repoName = attestation ids
    mapping(string => mapping(string => bytes32[])) public devAttestations;
    address public _owner;

    constructor(IEAS eas) SchemaResolver(eas) {
        _owner = msg.sender;
    }

    /**
    * Decodes the schema
    */
    function decode(bytes memory data)
        public
        pure
        returns (string memory username, string memory repository, uint256 pullRequestCount)
    {
        (username, repository, , , , pullRequestCount) = abi.decode(data, (string, string, string, string, string, uint256));
        return (username, repository, pullRequestCount);
    }


    /**
     * This is an bottom up event, called from the attest contract
     */
    function onAttest(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal override returns (bool) {
        (string memory username, string memory repository, uint256 pullRequestCount) = decode(attestation.data);
        devAttestations[username][repository].push(attestation.uid);
        return true;
    }

    /**
     * This is an bottom up event, called from the attest contract
     */
    function onRevoke(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal override returns (bool) {
       (string memory username, string memory repository, ) = decode(attestation.data);
        bytes32[] storage attestations = devAttestations[username][repository];
        for(uint i = 0; i < attestations.length; i++) {
            if(attestations[i] == attestation.uid) {
                attestations[i] = attestations[attestations.length - 1];
                attestations.pop();
                break;
            }
        }
        devAttestations[username][repository] = attestations;
        return true;
    }

    function getPRCount(string memory repoName, string memory username) public view returns (uint256) {
        return devAttestations[username][repoName].length;
    }
}
