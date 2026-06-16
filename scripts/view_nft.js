const hre = require("hardhat");

const CONTRACT_ADDRESS = "NOVO_ENDEREÇO_AQUI";
const TOKEN_ID = process.argv[2] || 1;

async function main() {
  console.log("🔍 Viewing NFT #", TOKEN_ID);
  
  const contract = await hre.ethers.getContractAt("CosmicEvolvingNFT", CONTRACT_ADDRESS);
  
  const info = await contract.getEntityInfo(TOKEN_ID);
  const cosmicState = await contract.getCosmicState();
  
  console.log("\n📊 Entity Information:");
  console.log("  Type:", info.entityType);
  console.log("  Phase:", info.evolutionPhase);
  console.log("  DNA Seed:", info.seed.toString());
  console.log("  Birth Block:", info.birthBlock.toString());
  console.log("  Mutations:", info.mutationCount.toString());
  
  console.log("\n🌌 Cosmic State:");
  console.log("  Total Mints:", cosmicState.mints.toString());
  console.log("  Current Phase:", cosmicState.phase);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
