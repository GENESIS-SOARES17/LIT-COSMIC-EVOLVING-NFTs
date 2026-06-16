const hre = require("hardhat");

const CONTRACT_ADDRESS = "0x64798C42A3CF4139D664014fE685Df24CD23696b";

async function main() {
  const tokenId1 = parseInt(process.env.TOKEN1);
  const tokenId2 = parseInt(process.env.TOKEN2);
  
  if (!tokenId1 || !tokenId2) {
    console.log("Uso: TOKEN1=1 TOKEN2=2 npx hardhat run scripts/fuse.js --network liteforge");
    process.exit(1);
  }
  
  console.log(`🧬 Fundindo NFT #${tokenId1} + NFT #${tokenId2}...`);
  
  const contract = await hre.ethers.getContractAt("CosmicEvolvingNFT", CONTRACT_ADDRESS);
  
  const tx = await contract.fuseNFTs(tokenId1, tokenId2, { gasLimit: 2000000 });
  console.log("⏳ Transaction sent:", tx.hash);
  
  const receipt = await tx.wait();
  console.log("✅ Fusion confirmed!");
  
  const event = receipt.logs.find(log => {
    try {
      const parsed = contract.interface.parseLog(log);
      return parsed && parsed.name === "EntityFused";
    } catch {
      return false;
    }
  });
  
  if (event) {
    const parsed = contract.interface.parseLog(event);
    const newTokenId = parsed.args.newTokenId.toString();
    const isMutant = parsed.args.isMutant;
    
    console.log(`🌟 Novo NFT criado: #${newTokenId}`);
    console.log(`👨‍👩‍👧 Pais: #${tokenId1} + #${tokenId2}`);
    console.log(`⚡ Mutante: ${isMutant ? "SIM! RARO!" : "Não"}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
