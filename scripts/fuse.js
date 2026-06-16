const hre = require("hardhat");
const fs = require('fs');

const CONTRACT_ADDRESS = "0x887aD23913A2579f9B57f6D0a71D87C14EA2EF40";

async function main() {
  const token1 = parseInt(process.env.TOKEN1);
  const token2 = parseInt(process.env.TOKEN2);
  
  if (!token1 || !token2) {
    console.log("❌ Uso: TOKEN1=1 TOKEN2=2 npx hardhat run scripts/fuse.js --network liteforge");
    process.exit(1);
  }
  
  console.log(`🔥 Fundindo NFT #${token1} + NFT #${token2}...`);
  console.log(`📍 Contrato: ${CONTRACT_ADDRESS}`);
  console.log('');
  
  const contract = await hre.ethers.getContractAt("CosmicEvolvingNFT", CONTRACT_ADDRESS);
  
  try {
    const tx = await contract.fuseNFTs(token1, token2, { gasLimit: 500000 });
    console.log(`⏳ Transação enviada: ${tx.hash}`);
    
    const receipt = await tx.wait();
    console.log(`✅ Fusão confirmada! Block: ${receipt.blockNumber}`);
    console.log('');
    
    // Buscar evento
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
      console.log(`🌟 Novo NFT criado: #${parsed.args.newTokenId}`);
      console.log(`‍👩 Pais: #${token1} + #${token2}`);
      console.log(`⚡ Mutante: ${parsed.args.isMutant ? "SIM! RARO!" : "Não"}`);
    }
    
    // Salvar log
    const log = {
      token1,
      token2,
      txHash: tx.hash,
      blockNumber: receipt.blockNumber,
      timestamp: new Date().toISOString()
    };
    
    const logFile = `fusion-log-${Date.now()}.json`;
    fs.writeFileSync(logFile, JSON.stringify(log, null, 2));
    console.log(`\n💾 Log salvo em: ${logFile}`);
    
  } catch (error) {
    console.error(`❌ Erro na fusão:`, error.message);
    process.exit(1);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
