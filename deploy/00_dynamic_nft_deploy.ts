import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;

    const {deployer} = await getNamedAccounts();

    await deploy('DynamicNFT', {
        from: deployer,
        log: true,
        autoMine: true,
        args: ['KARMADEV', 'Karma Dev Reputation', "0xAAc8f41BC1d080B6a64b4a23348dF963Ace17E78"]
    });
};
export default func;
func.tags = ['DynamicNFT']

