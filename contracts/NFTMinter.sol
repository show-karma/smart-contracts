//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMinter is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor (string memory _name, string memory _symbol) ERC721(_name, _symbol){}

    function batchMint(address[] memory receivers, string[] memory tokenURIs) public onlyOwner {
      for(uint i=0; i<tokenURIs.length; i++) {
        mintToken(receivers[i], tokenURIs[i]);
      }
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

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal override {
      revert("Token transfer is disabled.");
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
      revert("Token transfer is disabled.");
    }
}
