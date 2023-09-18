//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "contracts/Resolvers/NFTUpdatingResolver.sol";
import "contracts/Resolvers/GithubLinkingResolver.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DynamicNFT is ERC721URIStorage {
  uint256 public nftCounter;
  NFTUpdatingResolver public nftResolver;
  GithubLinkResolver public githubResolver;
  mapping(uint256 => string) public nftRepo;
  address public _owner;

  constructor (string memory _name, string memory _symbol, address payable _attestationResolver, address payable _githubResolver) ERC721(_name, _symbol) {
    nftCounter = 0;
    nftResolver = NFTUpdatingResolver(_attestationResolver);
    githubResolver = GithubLinkResolver(_githubResolver);
    _owner = msg.sender;
  }

  function mintToken(address receiver, string memory repository) public {
    nftCounter += 1;
    _mint(receiver, nftCounter);
    nftRepo[nftCounter] = repository;
    _setTokenURI(nftCounter, formatTokenURI(nftCounter, repository));
  }

  function imageURI(uint256 tokenId, string memory repository) private view returns(string memory) {
   string memory svg = "data:image/svg+xml;utf8,<svg width='500' height='500' viewBox='0 0 285 350' fill='none' xmlns='http://www.w3.org/2000/svg'><path fill='black' d='M150,0 L75,200 L225,200 Z'></path><text x='150' y='125' font-size='60' text-anchor='middle' fill='white'>";
    svg = string(abi.encodePacked(svg, getCount(tokenId, repository), "</text></svg>"));
    return svg;
  }

  function getWalletInformation(address receiver) private view returns (string memory){
    return githubResolver.getUsernameOfAddress(receiver);
  }

  function getCount(uint256 tokenId, string memory repository) private view returns (string memory) {
    address receiver = ownerOf(tokenId);
    string memory githubUsername = getWalletInformation(receiver);
    uint256 counter = nftResolver.getPRCount(repository, githubUsername);
    return Strings.toString(counter);
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory) {
    return formatTokenURI(tokenId, nftRepo[tokenId]);
  }

  function formatTokenURI(uint256 tokenId, string memory repository) public view returns (string memory) {
      string memory svgImageURI = imageURI(tokenId, repository);
      string memory json = string(
          abi.encodePacked(
              '{"name":"SVG NFT", "description":"Karma Reputation NFT!", "attributes":"", "image":"',
              svgImageURI,
              '"}'
          )
      );

      string memory base64EncodedJson = Base64.encode(bytes(json));
      return string(abi.encodePacked("data:application/json;base64,", base64EncodedJson));
  }


}
