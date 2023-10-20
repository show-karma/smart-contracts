// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {SchemaResolver} from "@ethereum-attestation-service/eas-contracts/contracts/resolver/SchemaResolver.sol";
import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

// errors
error NotOwner();

contract DevSchemaResolver is SchemaResolver {

    struct AttestationData {
        bytes32 uid;
        string prUrl;
    }

    // attester -> username => repoName = attestation
    mapping(address => mapping(string => mapping(string => AttestationData[]))) public devAttestations;
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
        returns (string memory username, string memory repository, string memory pullrequestUrl)
    {
        (username, repository, , , pullrequestUrl) = abi.decode(data, (string, string, string, string, string));
        return (username, repository, pullrequestUrl);
    }


    /**
     * This is an bottom up event, called from the attest contract
     */
     function onAttest(Attestation calldata attestation,uint256 /*value*/) internal override returns (bool) {
    (string memory username, string memory repository, string memory pullrequestUrl) = decode(attestation.data);
      AttestationData memory newAttestation = AttestationData({
          uid: attestation.uid,
          prUrl: pullrequestUrl
          });
      devAttestations[attestation.attester][username][repository].push(newAttestation);
      return true;
    }

    /**
     * This is an bottom up event, called from the attest contract
     */
    function onRevoke(Attestation calldata attestation, uint256 /*value*/) internal override returns (bool) {
        (string memory username, string memory repository,) = decode(attestation.data);
            AttestationData[] storage attestations = devAttestations[attestation.attester][username][repository];
            for(uint i = 0; i < attestations.length; i++) {
                if(attestations[i].uid == attestation.uid) {
                    attestations[i] = attestations[attestations.length - 1];
                    attestations.pop();
                    break;}}
            devAttestations[attestation.attester][username][repository] = attestations;
        return true;
    }

    function getUserAttestation(string memory username, string memory repository, address attester) public view returns (AttestationData[] memory) {
        return devAttestations[attester][username][repository];
    }
}
