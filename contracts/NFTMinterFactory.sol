//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.2;
import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/transparent/TransparentUpgradeableProxy.sol";
import "./NFTMinter.sol";

contract NFTMinterFactory is Initializable, OwnableUpgradeable {
  mapping(address => mapping(string => address)) public contractOwner;
  event NewNFTContract(address _contract, address _owner, string _name, string _symbol);

  function initialize() public initializer {
    __Ownable_init();
  }

  function deployMinter(address _owner, string memory _name, string memory _symbol) onlyOwner public returns (address) {
    require(contractOwner[_owner][_symbol] == address(0));
    address minterImplAddress = address(new NFTMinter());
    TransparentUpgradeableProxy minterContract = new TransparentUpgradeableProxy(
        minterImplAddress,
        msg.sender,
        abi.encodeWithSelector(NFTMinter(address(0)).initialize.selector, _name, _symbol)
    );

    NFTMinter minter = NFTMinter(address(minterContract));
    minter.transferOwnership(_owner);
    emit NewNFTContract(address(minterContract), _owner, _name, _symbol);
    contractOwner[_owner][_symbol] = address(minterContract);
    //console.log(newContractId);
    //console.log(_owner);
    //console.log(address(minterContract));
    return address(minterContract);
  }

  function contractAddress(address _owner, string memory _symbol) public view returns (address) {
    return contractOwner[_owner][_symbol];
  }
}

