import { expect } from "chai";
import '@openzeppelin/hardhat-upgrades';
import { ethers, deployments, getNamedAccounts, getUnnamedAccounts, upgrades } from 'hardhat';
const {MockProvider} = require('ethereum-waffle');

describe("NFT Minter Factory", function () {
  let nftMinterFactory;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  let dai;

  const [wallet, otherWallet] = new MockProvider().getWallets();

  const {deploy} = deployments;

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    const NFTMinterFactory = await ethers.getContractFactory("NFTMinterFactory");
    nftMinterFactory = await upgrades.deployProxy(NFTMinterFactory);
    await nftMinterFactory.deployed();
  });

  describe("Deploy Minter", function() {
    it("Should deploy minter contract", async function() {
      await nftMinterFactory.deployMinter(addr1.address, "Zastrin Courses", "ZSTR");
      const address = await nftMinterFactory.contractAddress(addr1.address, "ZSTR");
      const NFTMinter = await ethers.getContractFactory("NFTMinter");
      const minter = (await NFTMinter.attach(address)).connect(addr1);
      expect(await minter.owner()).to.equal(addr1.address); 
      expect(await minter.name()).to.equal("Zastrin Courses"); 
      expect(await minter.symbol()).to.equal("ZSTR"); 
    });
  });
});

