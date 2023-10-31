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

    struct AttestationInfo {
        AttestationData[] attestations;
        uint256 additions;
        uint256 deletions;
    }

    // attester -> username => repoName = attestationsId[]
    mapping(address => mapping(string => mapping(string => bytes32[]))) public devAttestations;
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
        returns (string memory username, string memory repository, string memory pullrequestUrl, uint256 additions, uint256 deletions)
    {
        (username, repository, , , pullrequestUrl, additions, deletions) = abi.decode(data, (string, string, string, string, string, uint256, uint256));
        return (username, repository, pullrequestUrl, additions, deletions);
    }


    /**
     * This is an bottom up event, called from the attest contract
     */
     function onAttest(Attestation calldata attestation,uint256 /*value*/) internal override returns (bool) {
    (string memory username, string memory repository,,,) = decode(attestation.data);
      devAttestations[attestation.attester][username][repository].push(attestation.uid);
      return true;
    }

    /**
     * This is an bottom up event, called from the attest contract
     */
    function onRevoke(Attestation calldata attestation, uint256 /*value*/) internal override returns (bool) {
        (string memory username, string memory repository,,,) = decode(attestation.data);
            bytes32[] storage attestations = devAttestations[attestation.attester][username][repository];
            for(uint i = 0; i < attestations.length; i++) {
                if(attestations[i] == attestation.uid) {
                    attestations[i] = attestations[attestations.length - 1];
                    attestations.pop();
                    break;
                }
            }
            devAttestations[attestation.attester][username][repository] = attestations;
        return true;
    }

    function getUserAttestationInformation(string memory _username, string memory _repository, address _attester) 
    public view
    returns (AttestationInfo memory) {
        AttestationInfo memory attestationInfo;
        attestationInfo.additions = 0;
        attestationInfo.deletions = 0;

        bytes32[] memory attestationUids = devAttestations[_attester][_username][_repository];
        attestationInfo.attestations = new AttestationData[](attestationUids.length);

        for(uint i = 0; i < attestationUids.length; i++) {
            Attestation memory attest = _eas.getAttestation(attestationUids[i]);
            (,, string memory pullrequestUrl , uint256 additions, uint256 deletions ) = decode(attest.data);

            attestationInfo.attestations[i] = AttestationData({
                uid: attest.uid,
                prUrl: pullrequestUrl
            });

            attestationInfo.additions += additions;
            attestationInfo.deletions += deletions;
        }
        return attestationInfo;
    }


}
