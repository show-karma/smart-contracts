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
    uint256 orgId;
    string tokenName;
    string tokenSymbol;
    address contractAddress;
  }

  mapping(string => Org) public orgInfo;
  mapping(string => NFTContract) public nftContractInfo;
  mapping(uint256 => address) public orgContract;
  mapping(address => string) public addressOrg;
  event NewNFTContract(address _contract, string _name, string _symbol);
  event NewOrgRegistration(uint256 id, string _name, string _metaDataHash, address _owner);

  function initialize() public initializer {
    __Ownable_init();
  }

  function deployMinter(string memory _orgName, string memory _metaDataHash, address _orgOwner,
                        string memory _name, string memory _symbol) onlyOwner public returns (address) {
    uint orgId;
    if(orgInfo[_orgName].id == 0) {
      _orgIds.increment();
      orgId = _orgIds.current();
      orgInfo[_orgName] = Org(orgId, _orgName, _metaDataHash, _orgOwner);
      addressOrg[_orgOwner] = _orgName;
      emit NewOrgRegistration(orgId, _orgName, _metaDataHash, _orgOwner);
    }

    require(nftContractInfo[_symbol].contractAddress == address(0), "symbol already exists");
    NFTMinter minter = new NFTMinter(_name, _symbol);
    minter.transferOwnership(_orgOwner);
    nftContractInfo[_symbol] = NFTContract(orgId, _name, _symbol, address(minter));
    orgContract[orgId] = address(minter);
    emit NewNFTContract(address(minter), _name, _symbol);
    console.log(address(minter));
    return address(minter);
  }
}
