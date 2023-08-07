module.exports = async ({
  getNamedAccounts,
  deployments,
  getChainId,
  getUnnamedAccounts,
}) => {
  const {deploy} = deployments;
  const {deployer} = await getNamedAccounts();

  console.log(deployer);
  // the following will only deploy "GenericMetaTxProcessor" if the contract was never deployed or if the code changed since last deployment
  await deploy('KarmaERC20BalanceChecker', {
    from: deployer,
    gasLimit: 4000000,
    args: [],
  });
};
module.exports.tags = ['KarmaERC20BalanceChecker'];
