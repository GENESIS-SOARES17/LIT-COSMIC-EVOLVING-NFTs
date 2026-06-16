require("@nomiclabs/hardhat-ethers");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      evmVersion: "cancun",
      viaIR: true,
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

  networks: {
    liteforge: {
      url: process.env.LITEFORGE_RPC_URL || "https://liteforge.rpc.caldera.xyz/http",
      chainId: 4441,
      accounts: process.env.PRIVATE_KEY
        ? [process.env.PRIVATE_KEY]
        : []
    }
  }
};
