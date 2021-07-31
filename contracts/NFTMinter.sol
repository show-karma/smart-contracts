//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract NFTMinter is Initializable, ERC721URIStorageUpgradeable, OwnableUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;

    function initialize(string memory _name, string memory _symbol) public initializer {
      __ERC721_init(_name, _symbol);
      __Ownable_init();
    }

    function mintToken(address receiver, string memory tokenURI) public onlyOwner
        returns (uint256)
    {
        _tokenIds.increment();

        uint256 newTokenId = _tokenIds.current();
        _mint(receiver, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        return newTokenId;
    }
}
