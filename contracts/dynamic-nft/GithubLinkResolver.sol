// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {SchemaResolver} from "@ethereum-attestation-service/eas-contracts/contracts/resolver/SchemaResolver.sol";
import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";


contract GithubLinkResolver is SchemaResolver {
    mapping(string => address) public handleToAddress;
    mapping(address => string) public addressToHandle;
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
        returns (string memory githubHandle)
    {
        (githubHandle) = abi.decode(data, (string));
    }

    /**
     * This is a bottom-up event, called from the attest contract
     */
    function onAttest(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal override returns (bool) {
        (string memory githubHandle) = decode(attestation.data);
        handleToAddress[githubHandle] = attestation.recipient;
        addressToHandle[attestation.recipient] = githubHandle;
        return true;
    }

    /**
     * This is a bottom-up event, called from the attest contract
     */
    function onRevoke(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal override returns (bool) {
        (string memory githubHandle) = decode(attestation.data);
        delete handleToAddress[githubHandle]; // Use delete to clear the mapping entry
        delete addressToHandle[attestation.recipient]; 
        
        return true;
    }

    function getAddressOfGithubHandle(string memory githubHandle) public view returns (address) {
        return handleToAddress[githubHandle];
    }

    function getUsernameOfAddress(address publicAddress) public view returns (string memory){
        return addressToHandle[publicAddress];
    }
}
