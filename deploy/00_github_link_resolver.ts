import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;

    const {deployer} = await getNamedAccounts();

    await deploy('GithubLinkResolver', {
        from: deployer,
        log: true,
        autoMine: true,
        args: ["0x4200000000000000000000000000000000000021"]
    });
};
export default func;
func.tags = ['GithubLinkResolver']
