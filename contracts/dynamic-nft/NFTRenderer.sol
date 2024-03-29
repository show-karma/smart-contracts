//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
interface NFTRenderer {
  function formatTokenURI(address owner, string memory nftName, string memory metadata, uint256 tokenId) external view returns (string memory);
  function imageURI(address tokenOwner, string memory metadata) external view returns(string memory);
  function isEligibleToMint(address tokenOwner, string memory metadata)  external view returns (bool);
}
