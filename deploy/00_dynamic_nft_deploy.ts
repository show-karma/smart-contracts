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
        args: ['KARMADEV', 'Karma Dev Reputation', "0x84d2De05B84a0663680566928974eE31d9F4ab41"]
    });
};
export default func;
func.tags = ['DynamicNFT']

