import '@nomiclabs/hardhat-waffle';
import '@openzeppelin/hardhat-upgrades';
import 'hardhat-deploy';
import 'solidity-coverage';
import "hardhat-watcher";
import 'hardhat-abi-exporter';
import { task } from "hardhat/config";
import { getImplementationAddress } from '@openzeppelin/upgrades-core';

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html

task("accounts", "Prints the list of accounts", async (args, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

task("latest_block", "Prints the latest block number", async(args, hre) => {
  await hre.ethers.provider.getBlockNumber().then((blockNumber) => {
    console.log("Current block number: " + blockNumber);
  });
});

task("impl_address", "Prints the implementation address", async(args, hre) => {
  const currentImplAddress = await getImplementationAddress(hre.ethers.provider, '0x1E06A5F27f3b23Eb1AF450193fADef21A0D35207');
  console.log("Current impl address: " + currentImplAddress);
});


// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */

const { infuraApiKey, privateKey } = require('./secrets.json');

export default {
  solidity: {
    version: "0.8.2",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000
      }
    }
  },
  networks: {
    ropsten: {
      url: `https://ropsten.infura.io/v3/${infuraApiKey}`,
      accounts: [privateKey],
      saveDeployments: true
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${infuraApiKey}`,
      accounts: [privateKey],
      saveDeployments: true
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${infuraApiKey}`,
      accounts: [privateKey],
      saveDeployments: true
    },
    arb_testnet: {
      url: `https://arb-rinkeby.g.alchemy.com/v2/L4sUzq5YUpIY-D7IA3l230OhO6wFhghm`,
      accounts: [privateKey],
      saveDeployments: true
    },
    arbitrum: {
      gasPrice: 120000000,
      url: `https://arb-mainnet.g.alchemy.com/v2/PiUO5Mmv0Gx2suXU3HN2xKliU2VaRjlf`,
      accounts: [privateKey],
      saveDeployments: true
    },
    polygon_mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/u5NVwv-g9yoWK2pGpOvlSmbUH9AEkH_e`,
      accounts: [privateKey],
      gasPrice: 1000000000,
      saveDeployments: true
    },
    polygon: {
      url: `https://polygon-mainnet.g.alchemy.com/v2/r9n4TSj6T3p7YuwgbvcBYXGPXme0DreC`,
      gasPrice: 30000000000,
      accounts: [privateKey],
      saveDeployments: true
    },
    xdai: {
      url: `https://dai.poa.network/`,
      gasPrice: 30000000000,
      accounts: [privateKey],
      saveDeployments: true
    }


  },
  namedAccounts: {
    deployer: {
      default: 0, // here this will by default take the first account as deployer
    }
  },
  watcher: {
    compilation: {
      tasks: ["compile"],
    },
    test: {
      tasks: [{ command: 'test', params: { testFiles: ['{path}'] } }],
      files: ['./test/**/*.ts'],
      verbose: true
    }
  }
};


