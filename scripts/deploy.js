const hre = require("hardhat");

async function main() {
  console.log("🚀 Deploying CosmicEvolvingNFT...");

  const Factory = await hre.ethers.getContractFactory("CosmicEvolvingNFT");
  const contract = await Factory.deploy();

  await contract.deployed();

  console.log("==================================");
  console.log("✅ Deploy realizado com sucesso!");
  console.log("📍 Endereço:", contract.address);
  console.log("==================================");
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
