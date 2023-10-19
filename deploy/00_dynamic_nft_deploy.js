module.exports = async ({
    getNamedAccounts,
    deployments,
    getChainId,
    getUnnamedAccounts,
  }) => {
    const {deploy} = deployments;
    const {deployer} = await getNamedAccounts();
  
    /*await deploy('DynamicNFT', {
      from: deployer,
      gasLimit: 4000000,
      args: ['KARMADEV', 'Karma Dev Reputation', '0x67d269191c92caf3cd7723f116c85e6e9bf55933'],
    });*/
    await deploy('DevNFTRenderer', {
      from: deployer,
      gasLimit: 4000000,
      args: ['0x47Fc0eB55A0Be616Fd68E4d99cff6304457dFA69', '0x088D11816A414015333c338dEE0644aA69a338B4'],
    });

  };
  module.exports.tags = ['DevNFTRenderer'];
  
