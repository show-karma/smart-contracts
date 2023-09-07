//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "base64-sol/base64.sol";
import "./EASResolver/NFTUpdatingResolver.sol";

contract DynamicNFT is ERC721URIStorage {
  uint256 public tokenId;
  NFTUpdatingResolver public resolver;
  string public repoName;

  constructor (string memory _name, string memory _symbol, string memory _repoName, address payable _attestationResolver) ERC721(_name, _symbol) {
    tokenId = 0;
    resolver = NFTUpdatingResolver(_attestationResolver);
    repoName = _repoName;
  }

  function mintToken(address receiver) public returns (uint256) {
      tokenId += 1;
      _mint(receiver, tokenId);
      _setTokenURI(tokenId, formatTokenURI(receiver));
      return tokenId;
  }

  function imageURI(address receiver) private returns(string memory) {
    return string.concat("<svg width='500' height='500' viewBox='0 0 285 350' fill='none' xmlns='http://www.w3.org/2000/svg'><pathfill='black'd='M150,0,L75,200,L225,200,Z'></path><text x='150' y='125' font-size='60'text-anchor='middle' fill='white'>",
                         getCount(receiver), ", 1</text></svg>");
  }

  function getCount(address receiver) private returns (string memory) {
    string(abi.encode(resolver.getPRCount(repoName, receiver)));
  }

  function formatTokenURI(address receiver) public returns (string memory) {
        return string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name":"',
                                "SVG NFT", // You can add whatever name here
                                '", "description":"Karma Reputation NFT!", "attributes":"", "image":"',imageURI(receiver),'"}'
                            )
                        )
                    )
                )
            );
  }

}

