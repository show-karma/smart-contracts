//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "./DevSchemaResolver.sol";
import "./GithubLinkResolver.sol";
import "./NFTRenderer.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DevNFTRenderer is NFTRenderer {
  uint256 public nftCounter;
  DevSchemaResolver public schemaResolver;
  GithubLinkResolver public githubResolver;
  mapping(uint256 => string) public nftRepo;
  address public _owner;

  constructor (address payable _schemaResolver, address payable _githubResolver) {
    nftCounter = 0;
    schemaResolver = DevSchemaResolver(_schemaResolver);
    githubResolver = GithubLinkResolver(_githubResolver);
    _owner = msg.sender;
  }

  function formatTokenURI(address tokenOwner, string memory repository) public view returns (string memory) {
      string memory svgImageURI = imageURI(tokenOwner, repository);
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

  function imageURI(address tokenOwner, string memory repository) public view returns(string memory) {
    string memory svg = "data:image/svg+xml;utf8,<svg width='500' height='500' viewBox='0 0 285 350' fill='none' xmlns='http://www.w3.org/2000/svg'><path fill='black' d='M150,0 L75,200 L225,200 Z'></path><text x='150' y='125' font-size='60' text-anchor='middle' fill='white'>";
    svg = string(abi.encodePacked(svg, getCount(tokenOwner, repository), "</text></svg>"));
    return svg;
  }

  function getWalletInformation(address receiver) private view returns (string memory){
    return githubResolver.getUsernameOfAddress(receiver);
  }

  function getCount(address tokenOwner, string memory repository) private view returns (string memory) {
    string memory githubUsername = getWalletInformation(tokenOwner);
    uint256 counter = schemaResolver.getPRCount(repository, githubUsername);
    return Strings.toString(counter);
  }

}