const hre = require("hardhat");

const CONTRACT_ADDRESS = "NOVO_ENDEREÇO_AQUI";

async function main() {
  console.log("🧬 Checking for mutations...\n");
  
  const contract = await hre.ethers.getContractAt("CosmicEvolvingNFT", CONTRACT_ADDRESS);
  const nextId = await contract.nextTokenId();
  const currentBlock = await hre.ethers.provider.getBlockNumber();
  
  console.log(`Current Block: ${currentBlock}`);
  console.log(`Total Entities: ${nextId - 1}\n`);
  
  for (let tokenId = 1; tokenId < nextId; tokenId++) {
    try {
      const info = await contract.getEntityInfo(tokenId);
      const blocksSinceLastMutation = currentBlock - Number(info.lastMutationBlock);
      
      console.log(`Entity #${tokenId} - ${info.entityType}`);
      console.log(`  Blocks Since Mutation: ${blocksSinceLastMutation}`);
      
      if (blocksSinceLastMutation >= 1000) {
        console.log(`  ✅ Ready to mutate!`);
        
        const owner = await contract.ownerOf(tokenId);
        const [signer] = await hre.ethers.getSigners();
        
        if (owner.toLowerCase() === signer.address.toLowerCase()) {
          console.log(`  🔄 Executing mutation...`);
          const tx = await contract.mutateEntity(tokenId);
          await tx.wait();
          console.log(`  ✅ Mutated!`);
        } else {
          console.log(`  ⚠️  Not owner`);
        }
      } else {
        console.log(`  ⏳ Wait ${1000 - blocksSinceLastMutation} more blocks`);
      }
      console.log('');
    } catch (e) {
      console.log(`⚠️  Error: ${e.message}\n`);
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
