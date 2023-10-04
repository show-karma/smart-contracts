//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
interface NFTRenderer {
  function formatTokenURI(address owner, string memory metadata) external view returns (string memory);
  function imageURI(address tokenOwner, string memory metadata) external view returns(string memory);
}
