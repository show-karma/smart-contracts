//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "./NFTRenderer.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DynamicNFT is ERC721URIStorage {
  uint256 public tokenId;
  NFTRenderer public nftRenderer;
  mapping(uint256 => string) public nftMetadata;
  mapping(address => mapping(string => uint256)) public nftToOwner;
  address public _owner;

  constructor (string memory _name, string memory _symbol, address _nftRenderer) ERC721(_name, _symbol) {
    tokenId = 0;
    nftRenderer = NFTRenderer(_nftRenderer);
    _owner = msg.sender;
  }

  function mintToken(address receiver, string memory metadata) public {
    require(nftRenderer.isEligibleToMint(receiver, metadata), "User doesn't have any contributions");
    tokenId += 1;
    _mint(receiver, tokenId);
    nftMetadata[tokenId] = metadata;
    nftToOwner[receiver][metadata] = tokenId;
  }

  function tokenURI(uint256 id) public view override returns (string memory) {
    address tokenOwner = ownerOf(id);
    return nftRenderer.formatTokenURI(tokenOwner, name(), nftMetadata[id], id);
  }

  function getTokenIdByAddressAndMetadata(address owner, string memory metadata) public view returns (uint256) {
    return nftToOwner[owner][metadata];
  }

}
