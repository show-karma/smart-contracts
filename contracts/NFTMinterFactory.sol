//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMinterFactory is Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _contractIds;
  mapping(uint256 => mapping(address => address)) contractIdOwner;
  event NewNFTContract(uint256 _contractId, address _contract, address _owner);

  function deployMinter(address _owner, string memory _name, string memory _symbol) public {
    NFTMinter minterContract = new NFTMinter(_name, _symbol);
    uint256 newContractId = _contractIds.current();
    contractIdOwner[newContractId][_owner] = address(minterContract);
    minterContract.transferOwnership(msg.sender);
    emit NewNFTContract(newContractId, address(minterContract), _owner);
    console.log(newContractId);
    console.log(_owner);
    console.log(address(minterContract));
  }
}

contract NFTMinter is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {}

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
