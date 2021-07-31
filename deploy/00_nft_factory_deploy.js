const {getAddress} = require("@ethersproject/address")
const {BigNumber} = require("@ethersproject/BigNumber")

module.exports = async ({getNamedAccounts, deployments, upgrades, network}) => {
  const {log} = deployments;
  

  const NFTMinterFactory = await ethers.getContractFactory("NFTMinterFactory");

  const factory = await upgrades.deployProxy(NFTMinterFactory);
  await factory.deployed();

  const implementationStorage = await ethers.provider.getStorageAt(
    factory.address,
    '0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc'
  );
  const implementationAddress = getAddress(
    BigNumber.from(implementationStorage).toHexString()
  );

  log(
    `NFTMinterFactory deployed as Proxy at : ${factory.address}, implementation: ${implementationAddress}`
  );


  const NFTMinterFactoryArtifact = await deployments.getExtendedArtifact('NFTMinterFactory');

  const factoryAsDeployment = {
    address: factory.address,
    ...NFTMinterFactory,
    // TODO :transactionHash: transactionHash for Proxy deployment
    // args ?
    // linkedData ?
    // receipt?
    // libraries ?
  };
  await deployments.save('NFTMinterFactoryArtifact', factoryAsDeployment);

}

module.exports.tags = ['NFTMinterFactory'];
