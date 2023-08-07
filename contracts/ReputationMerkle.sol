//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "hardhat/console.sol";

contract ReputationMerkle is Initializable, OwnableUpgradeable {
  bytes32 public merkleRoot;

  mapping(address => bool) public isClaimed;

  function initialize() public initializer {
    __Ownable_init();
  }

  function setMerkleRoot(bytes32 merkleRoot_) onlyOwner public {
      merkleRoot = merkleRoot_;
  }

  function getEncodePacked(address account, uint256 amount) public view returns (bytes memory) {
    return abi.encodePacked(account, amount);
  }

  function getNode(address account, uint256 amount) public view returns (bytes32) {
    return keccak256(
        abi.encodePacked(account, amount)
    );
  }

  function isValid(bytes32[] calldata merkleProof, bytes32 node) public view returns (bool) {
      return MerkleProof.verify(
          merkleProof,
          merkleRoot,
          node
      );
  }

  function claim(
      address account,
      uint256 amount,
      bytes32[] calldata merkleProof
  ) external {
      require(!isClaimed[account], 'Already claimed.');
      bytes32 node = keccak256(
          abi.encodePacked(account, amount)
      );
      bool isValidProof = MerkleProof.verify(
          merkleProof,
          merkleRoot,
          node
      );
      require(isValidProof, 'Invalid proof.');

      isClaimed[account] = true;
      // Mint amount tokens to account
  }

}
