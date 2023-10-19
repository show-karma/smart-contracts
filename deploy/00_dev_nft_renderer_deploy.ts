import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const {deployments, getNamedAccounts} = hre;
    const {deploy} = deployments;

    const {deployer} = await getNamedAccounts();

    await deploy('DevNFTRenderer', {
        from: deployer,
        log: true,
        autoMine: true,
        args: ["0x8f16aD3e4F871c820FD3AB9C919bf93A30DA6d17", "0x6455E470f9Ecee5755930c9979b559768BF53170"]
    });
};
export default func;
func.tags = ['DevNFTRenderer']

