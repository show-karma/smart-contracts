const {getAddress} = require("@ethersproject/address")
const {BigNumber} = require("@ethersproject/BigNumber")

module.exports = async ({getNamedAccounts, deployments}) => {
  const {deploy} = deployments;
  const {deployer} = await getNamedAccounts();
  await deploy('NFTMinterFactory', {
    from: deployer,
    log: true,
  });
};
module.exports.tags = ['NFTMinterFactory'];
