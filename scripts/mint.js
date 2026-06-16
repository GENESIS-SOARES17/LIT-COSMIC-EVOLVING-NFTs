const hre = require("hardhat");

const CONTRACT_ADDRESS = "0x64798C42A3CF4139D664014fE685Df24CD23696b";

async function main() {
  console.log("🎨 Minting Cosmic Entity...");
  
  const contract = await hre.ethers.getContractAt("CosmicEvolvingNFT", CONTRACT_ADDRESS);
  
  // Aumentar gas limit
  const tx = await contract.mintEntity({
    gasLimit: 1000000
  });
  
  console.log("⏳ Transaction sent:", tx.hash);
  
  const receipt = await tx.wait();
  console.log("✅ Transaction confirmed!");
  
  const event = receipt.logs.find(log => {
    try {
      const parsed = contract.interface.parseLog(log);
      return parsed && parsed.name === "EntityBorn";
    } catch {
      return false;
    }
  });
  
  if (event) {
    const parsed = contract.interface.parseLog(event);
    const tokenId = parsed.args.tokenId.toString();
    console.log(" NFT Minted! Token ID:", tokenId);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
