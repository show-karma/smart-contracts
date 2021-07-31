import { expect } from "chai";
import '@openzeppelin/hardhat-upgrades';
import { ethers, deployments, getNamedAccounts, getUnnamedAccounts, upgrades } from 'hardhat';
const {MockProvider} = require('ethereum-waffle');

describe("NFT Minter", function () {
  let nftMinter;
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
    const nftMinterFactory = await upgrades.deployProxy(NFTMinterFactory);
    await nftMinterFactory.deployed();
    await nftMinterFactory.deployMinter(addr1.address, "Zastrin Courses", "ZSTR");
    const address = await nftMinterFactory.contractAddress(addr1.address, "ZSTR");
    const NFTMinter = await ethers.getContractFactory("NFTMinter");
    nftMinter = (await NFTMinter.attach(address)).connect(addr1);
  });

  describe("Minter", function() {
    it("Should mint NFT", async function() {
      await nftMinter.mintToken(addr2.address, 'http://ipfs.io/image'); 
      expect(await nftMinter.ownerOf(1)).to.equal(addr2.address); 
      expect(await nftMinter.balanceOf(addr2.address)).to.equal(1); 
    });
  });
});


