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
        args: ['Karma Dynamic NFT', 'KARMA REP']
    });
};
export default func;
func.tags = ['DynamicNFT']
