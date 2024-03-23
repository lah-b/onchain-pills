require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.24",
  etherscan: {
    apiKey: {
      base: `${process.env.BASE_API_KEY}`,
      base_sepolia: `${process.env.BASE_SEP_API_KEY}`,
    },
    customChains: [
      {
        network: "base_sepolia",
        chainId: 84532,
        urls: {
          apiURL: "https://api-sepolia.basescan.org/api",
          browserURL: "https://sepolia.base.org",
        },
      },
      {
        network: "base",
        chainId: 8453,
        urls: {
          apiURL: "https://api.basescan.org/api",
          browserURL: "https://mainnet.base.org",
        },
      },
    ],
  },
  networks: {
    base_sepolia: {
      url: `https://base-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_BASE_SEP_KEY}`,
      accounts: [`${process.env.SEPOLIA_PRIVATE_KEY}`],
    },
    base: {
      url: `https://base-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_BASE_KEY}`,
      accounts: [`${process.env.BASE_PRIVATE_KEY}`],
    },
  },
};
