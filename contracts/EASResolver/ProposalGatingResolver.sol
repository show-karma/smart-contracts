// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {SchemaResolver} from "@ethereum-attestation-service/eas-contracts/contracts/resolver/SchemaResolver.sol";
import {IEAS} from "@ethereum-attestation-service/eas-contracts/contracts/IEAS.sol";
import {Attestation} from "@ethereum-attestation-service/eas-contracts/contracts/Common.sol";

contract ProposalGatingResolver is SchemaResolver {
    // tokenAddress => (tokenChainId => attester) = 1
    mapping(address => mapping(uint24 => mapping(address => uint8))) private daoAdmins;
    address private _owner;

    constructor(IEAS eas) SchemaResolver(eas) {
        _owner = msg.sender;
    }

    /**
     * Decodes the schema
     */
    function decode(bytes memory data)
        public
        pure
        returns (address tokenAddress, uint24 tokenChainId)
    {
        (tokenAddress, tokenChainId, , ) = abi.decode(data, (address, uint24, string, bool));
        return (tokenAddress, tokenChainId);
    }

    function canAttest(
        address attester,
        address tokenAddress,
        uint24 tokenChainId
    ) public view returns (bool) {
        return daoAdmins[tokenAddress][tokenChainId][attester] == 1 || attester == _owner;
    }

    function enlist(
        address addr,
        address tokenAddress,
        uint24 tokenChainId
    ) public virtual {
        // Admin can attest and also add other admins
        require(canAttest(msg.sender, tokenAddress, tokenChainId), "Not admin");
        daoAdmins[tokenAddress][tokenChainId][addr] = 1;
    }

    function delist(
        address addr,
        address tokenAddress,
        uint24 tokenChainId
    ) public {
        // Admin can attest and also remove other admins
        require(canAttest(msg.sender, tokenAddress, tokenChainId), "Not admin");
        daoAdmins[tokenAddress][tokenChainId][addr] = 0;
    }

    /**
     * This is an bottom up event, called from the attest contract
     */
    function onAttest(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal view override returns (bool) {
        (address tokenAddress, uint24 tokenChainId) = decode(attestation.data);
        return canAttest(attestation.attester, tokenAddress, tokenChainId);
    }

    /**
     * This is an bottom up event, called from the attest contract
     */
    function onRevoke(
        Attestation calldata attestation,
        uint256 /*value*/
    ) internal view override returns (bool) {
        (address tokenAddress, uint24 tokenChainId) = decode(attestation.data);
        return canAttest(attestation.attester, tokenAddress, tokenChainId);
    }
}
