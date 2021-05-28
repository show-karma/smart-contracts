import { expect } from "chai";
import '@openzeppelin/hardhat-upgrades';
import { ethers, deployments, getNamedAccounts, getUnnamedAccounts, upgrades } from 'hardhat';
const {MockProvider} = require('ethereum-waffle');

describe("Boring Crypto", function () {
  let boringCrypto;
  let owner;
  let addr1;
  let addr2;
  let addrs;
  let dai;

  const [wallet, otherWallet] = new MockProvider().getWallets();

  const {deploy} = deployments;

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    const Dai = await ethers.getContractFactory("DaiToken");
    dai = await Dai.deploy();
    await dai.deployed();
    dai.mint(owner.address, ethers.utils.parseUnits("50", '18'));

    const BoringCrypto = await ethers.getContractFactory("BoringCrypto");
    boringCrypto = await upgrades.deployProxy(BoringCrypto, [dai.address]);
    await boringCrypto.deployed();
  });

  describe("Deployment", function () {
    it("Should set the dai token", async function () {
      //console.log(await mockDai.totalSupply());
      expect(await boringCrypto.dai()).to.equal(dai.address);
    });
  });

  describe("Deposit Dai to vault", function() {
    it("Should mint treasury karma", async function() {
      await boringCrypto.mintKarma();
      expect(await boringCrypto.treasuryKarma()).to.equal('1000000000000000000000'); 
    });
  });

  describe("User Registration", function() {
    beforeEach(async () => {
      await boringCrypto.mintKarma();
      let registrationFee = ethers.utils.parseUnits("50", '18');
      await dai.approve(boringCrypto.address, registrationFee);
    });
    
    it("Should transfer dai to bc contract", async function() {
      let registrationFee = ethers.utils.parseUnits("50", '18');
      expect(await dai.balanceOf(boringCrypto.address)).to.equal('0'); 
      await boringCrypto.register(registrationFee);
      expect(await dai.balanceOf(boringCrypto.address)).to.equal(registrationFee); 
    });

    it("Should transfer karma from treasury to user", async function() {
      let registrationFee = ethers.utils.parseUnits("50", '18');
      let totalKarma = ethers.utils.parseUnits("1000", '18');
      expect(await boringCrypto.treasuryKarma()).to.equal(totalKarma); 
      await boringCrypto.register(registrationFee);
      let remainingKarma = ethers.utils.parseUnits("950", '18');
      expect(await boringCrypto.treasuryKarma()).to.equal(remainingKarma); 
      expect(await boringCrypto.getUserKarma(owner.address)).to.equal(registrationFee); 
    });

    it("Should fail if user does not transfer minimum required for registration", async function() {
      let registrationFee = ethers.utils.parseUnits("40", '18');
      let totalKarma = ethers.utils.parseUnits("1000", '18');
      await expect(boringCrypto.register(registrationFee)).to.be.revertedWith('Insufficient Dai');
    });

    it("Should fail if token not approved for transfer", async function() {
      let registrationFee = ethers.utils.parseUnits("50", '18');
      await dai.approve(boringCrypto.address, 10);
      await expect(boringCrypto.register(registrationFee)).to.be.reverted;
    });
  });


  describe("User Deregistration", function() {
    beforeEach(async () => {
      await boringCrypto.mintKarma();
      let registrationFee = ethers.utils.parseUnits("50", '18');
      await dai.approve(boringCrypto.address, registrationFee);
      await boringCrypto.register(registrationFee);
    });

    it("should transfer dai to user withholding 5 Dai", async () => {
      let returnBalance = ethers.utils.parseUnits("45", '18');
      expect(await dai.balanceOf(owner.address)).to.equal(0); 
      await boringCrypto.deregister();
      expect(await dai.balanceOf(owner.address)).to.equal(returnBalance); 
    });

    it("should update user and treasury karma", async () => {
      let totalKarma = ethers.utils.parseUnits("1000", '18');
      let balanceTreasuryKarma = ethers.utils.parseUnits("950", '18');
      let registrationFee = ethers.utils.parseUnits("50", '18');
      expect(await boringCrypto.getUserKarma(owner.address)).to.equal(registrationFee); 
      expect(await boringCrypto.treasuryKarma()).to.equal(balanceTreasuryKarma); 
      await boringCrypto.deregister();
      expect(await boringCrypto.getUserKarma(owner.address)).to.equal(0); 
      expect(await boringCrypto.treasuryKarma()).to.equal(totalKarma); 
    });

    it("should fail if insufficient karma", async () => {
      // Empty the karma
      await boringCrypto.deregister();
      await expect(boringCrypto.deregister()).to.be.revertedWith('Insufficient karma balance');
    });
  });

});

