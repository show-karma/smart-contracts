// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import {SchemaResolver} from "./SchemaResolver.sol";

import {IEAS, Attestation} from "./IEAS.sol";

contract WhitelistResolver is SchemaResolver {
    mapping(address => string[]) private whitelisted;
    address private _owner;

    constructor(IEAS eas) SchemaResolver(eas) {
        _owner = msg.sender;
    }

    /**
     * Decode bytes to string
     */
    function toString(bytes memory data) public pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(2 + data.length * 2);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < data.length; i++) {
            str[2 + i * 2] = alphabet[uint256(uint8(data[i] >> 4))];
            str[3 + i * 2] = alphabet[uint256(uint8(data[i] & 0x0f))];
        }
        return string(str);
    }

    /**
     * Check if a string is contained in an array
     */
    function arrayContains(string[] memory array, string memory needle)
        private
        pure
        returns (bool)
    {
        for (uint256 i = 0; i < array.length; i++) {
            if (keccak256(bytes(array[i])) == keccak256(bytes(needle))) {
                return true;
            }
        }
        return false;
    }

    /**
     *  Returns the daoId based on tokenAddress and tokenChainId
     */
    function getDaoId(address tokenAddress, uint24 tokenChainId)
        private
        pure
        returns (string memory)
    {
        string memory _address = toString(abi.encodePacked(tokenAddress));
        string memory _chainId = toString(abi.encodePacked(tokenChainId));
        return toString(abi.encodePacked(_address, _chainId));
    }

    /**
     * Decodes the schema
     */
    function decode(bytes memory data)
        public
        pure
        returns (address tokenAddress, uint24 tokenChainId)
    {
        string memory daoName;
        bool goodGovCitizen;
        (tokenAddress, tokenChainId, daoName, goodGovCitizen) = abi.decode(data, (address, uint24, string, bool));
        return (tokenAddress, tokenChainId);
    }

    /**
     * Check if the attester can attest
     */
    function canAttest(
        address attester,
        address tokenAddress,
        uint24 tokenChainId
    ) public view returns (bool) {
        string memory daoId = getDaoId(tokenAddress, tokenChainId);
        return arrayContains(whitelisted[attester], daoId) || attester == _owner;
    }

    /**
     * Add to whitelist
     */
    function enlist(
        address addr,
        address tokenAddress,
        uint24 tokenChainId
    ) public virtual {
        string memory daoId = getDaoId(tokenAddress, tokenChainId);

        require(
            arrayContains(whitelisted[msg.sender], daoId) ||
                msg.sender == _owner,
            "Address not allowed to enlist."
        );
        whitelisted[addr].push(daoId);
    }

    /**
     * Remove the delegate from the whitelist
     */
    function delist(
        address addr,
        address tokenAddress,
        uint24 chainId
    ) public {
        string memory daoId = getDaoId(tokenAddress, chainId);

        require(
            arrayContains(whitelisted[msg.sender], daoId) ||
                msg.sender == _owner,
            "Address not allowed to delist."
        );
        whitelisted[addr].push(daoId);
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
