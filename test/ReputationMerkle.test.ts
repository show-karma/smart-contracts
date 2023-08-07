import { expect } from "chai";
import '@openzeppelin/hardhat-upgrades';
import { ethers, deployments, getNamedAccounts, getUnnamedAccounts, upgrades } from 'hardhat';
const { MerkleTree } = require('merkletreejs')
import { keccak256 } from "@ethersproject/keccak256";
const {MockProvider} = require('ethereum-waffle');

describe("Reputation Merkle", function () {
  let merkleContract;
  let ReputationMerkle;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  let dai;

  const [wallet, otherWallet] = new MockProvider().getWallets();

  const {deploy} = deployments;

  const delegates = [['0xf768f5F340e89698465Fc7C12F31cB485fFf98D2','1000'],
    ['0x8d07d225a769b7af3a923481e1fdf49180e6a265', '2000'],
    ['0x2b888954421b424c5d3d9ce9bb67c9bd47537d12', '100'],
    ['0x5e349eca2dc61abcd9dd99ce94d04136151a09ee', '3000'],
    ['0xb8c2c29ee19d8307cb7255e1cd9cbde883a267d5', '500']]

  const delegateLeaves = delegates.map ((d) => ethers.utils.solidityKeccak256(['address', 'uint256'], d))
  const tree = new MerkleTree(delegateLeaves, keccak256, { sortPairs: true });
  const merkleRoot = tree.getHexRoot();

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    ReputationMerkle = await ethers.getContractFactory("ReputationMerkle");
    merkleContract = await upgrades.deployProxy(ReputationMerkle);
    await merkleContract.deployed();
  });

  describe("Set merkle root", function() {
    it("Should fail if not owner", async function() {
      merkleContract = (await ReputationMerkle.attach(merkleContract.address)).connect(addr1);
      await expect(merkleContract.setMerkleRoot(merkleRoot)).to.be.revertedWith('Ownable: caller is not the owner'); 
    });

    it("Should set the root", async function() {
      await merkleContract.setMerkleRoot(merkleRoot); 
      expect(await merkleContract.merkleRoot()).to.equal(merkleRoot); 
    });
  });

  describe("Claim", function() {
    it("Should succeed if proof valid", async function() {
      await merkleContract.setMerkleRoot(merkleRoot); 
      const proof = tree.getHexProof(delegateLeaves[0]);
      await merkleContract.claim(delegates[0][0], delegates[0][1], proof);
      expect(await merkleContract.isClaimed(delegates[0][0])).to.equal(true); 
    });

    it("Should fail if proof is invalid", async function() {
    });

    it("Should fail if merkle root not set", async function() {
    });

    it("Should fail if merkle root is not valid", async function() {
    });

  });
  
});


