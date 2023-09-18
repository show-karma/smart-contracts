// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {SchemaResolver} from "@ethereum-attestation-service/eas-contracts/contracts/resolver/SchemaResolver.sol";
import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

contract GithubLinkResolver is SchemaResolver {
    mapping(string => address) public handleMap;
    mapping(address => string) public reversedMap;
    address public owner;

    constructor(IEAS eas) SchemaResolver(eas) {
        owner = msg.sender;
    }

    /**
     * Decodes the schema
     */
    function decode(bytes memory data)
        public
        pure
        returns (string memory githubUsername)
    {
        (githubUsername) = abi.decode(data, (string));
    }

    /**
     * This is a bottom-up event, called from the attest contract
     */
    function onAttest(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal override returns (bool) {
        (string memory githubUsername) = decode(attestation.data);
        handleMap[githubUsername] = attestation.recipient;
        reversedMap[attestation.recipient] = githubUsername;
        return true;
    }

    /**
     * This is a bottom-up event, called from the attest contract
     */
    function onRevoke(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal override returns (bool) {
        (string memory githubUsername) = decode(attestation.data);
        delete handleMap[githubUsername]; // Use delete to clear the mapping entry
        delete reversedMap[attestation.recipient]; 
        
        return true;
    }

    function getAddressOfGithubAndCounter(string memory githubUsername) public view returns (address) {
        return handleMap[githubUsername];
    }

    function getUsernameOfAddress(address publicAddress) public view returns (string memory){
        return reversedMap[publicAddress];
    }
}
