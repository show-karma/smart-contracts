// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {SchemaResolver} from "@ethereum-attestation-service/eas-contracts/contracts/resolver/SchemaResolver.sol";
import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";
import "contracts/Resolvers/GithubLinkingResolver.sol";

// errors
error NotOwner();

contract NFTUpdatingResolver is SchemaResolver {
    // repoName => githubUsername = 1
    mapping(string => mapping(string => uint256)) public _prCount;
    GithubLinkResolver public _githubResolver;
    address public _owner;

    constructor(IEAS eas, address payable githubResolver) SchemaResolver(eas) {
        _owner = msg.sender;
        _githubResolver = GithubLinkResolver(githubResolver);
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
        _prCount[repository][username] = pullRequestCount;
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
        _prCount[repository][username] = _prCount[repository][username] < 1 ? 0 : _prCount[repository][username] - 1 ;
        return true;
    }

    function getPRCount(string memory repoName, string memory developer) public view returns (uint256) {
        return _prCount[repoName][developer];
    }

    // Modifier -> Only contract owner can dispatch the function.
    modifier onlyOwner {
        if (msg.sender != _owner) revert NotOwner();
        _;
    }
}
