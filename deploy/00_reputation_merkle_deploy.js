const {getAddress} = require("@ethersproject/address")
const {BigNumber} = require("@ethersproject/BigNumber")

module.exports = async ({getNamedAccounts, deployments, upgrades, network}) => {
  const {log} = deployments;
  
  const ReputationMerkle = await ethers.getContractFactory("ReputationMerkle");

  const factory = await upgrades.deployProxy(ReputationMerkle);
  await factory.deployed();

  const implementationStorage = await ethers.provider.getStorageAt(
    factory.address,
    '0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc'
  );
  const implementationAddress = getAddress(
    BigNumber.from(implementationStorage).toHexString()
  );

  log(
    `ReputationMerkle deployed as Proxy at : ${factory.address}, implementation: ${implementationAddress}`
  );


  constReputationMerkleArtifact = await deployments.getExtendedArtifact('ReputationMerkle');

  const factoryAsDeployment = {
    address: factory.address,
    ...ReputationMerkle,
    // TODO :transactionHash: transactionHash for Proxy deployment
    // args ?
    // linkedData ?
    // receipt?
    // libraries ?
  };
  await deployments.save('ReputationMerkleArtifact', factoryAsDeployment);

}

module.exports.tags = ['ReputationMerkle'];
