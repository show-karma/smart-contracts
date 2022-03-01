//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "./NFTMinter.sol";

contract NFTMinterFactory is Initializable, OwnableUpgradeable {
  using CountersUpgradeable for CountersUpgradeable.Counter;
  CountersUpgradeable.Counter private _orgIds;

  struct Org {
    uint256 id;
    string name;
    string metaDataHash;
    address issuer;
  }

  struct NFTContract {
    string tokenName;
    string tokenSymbol;
    address contractAddress;
  }

  mapping(address => Org) public orgInfo;
  mapping(string => NFTContract) public nftContractInfo;
  mapping(uint256 => address) public orgToId;
  mapping(address => string[]) public orgContracts;

  event NewNFTContract(address _contract, string _name, string _symbol);
  event NewOrgRegistration(uint256 id, string _name, string _metaDataHash, address _owner);

  function initialize() public initializer {
    __Ownable_init();
  }

  function registerOrg(string memory _orgName, string memory _metaDataHash, address _orgOwner)
                      onlyOwner public {
    uint orgId;
    if(orgInfo[_orgOwner].id == 0) {
      _orgIds.increment();
      orgId = _orgIds.current();
      orgInfo[_orgOwner] = Org(orgId, _orgName, _metaDataHash, _orgOwner);
      orgToId[orgId] = _orgOwner;
      emit NewOrgRegistration(orgId, _orgName, _metaDataHash, _orgOwner);
    }
  }

  function deployMinter(string memory _name, string memory _symbol) public returns (address) {
    require(orgInfo[msg.sender].issuer != address(0), "Organization hasn't been registered");
    require(nftContractInfo[_symbol].contractAddress == address(0), "symbol already exists");

    NFTMinter minter = new NFTMinter(_name, _symbol);
    nftContractInfo[_symbol] = NFTContract(_name, _symbol, address(minter));
    orgContracts[msg.sender].push(_symbol);
    minter.transferOwnership(msg.sender);
    emit NewNFTContract(address(minter), _name, _symbol);
    console.log(address(minter));
    return address(minter);
  }

  function orgTokens(address _issuer) public view returns (string[] memory) {
    return orgContracts[_issuer];
  }
}
