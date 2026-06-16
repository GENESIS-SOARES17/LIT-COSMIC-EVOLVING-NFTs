const hre = require("hardhat");
const fs = require('fs');

const CONTRACT_ADDRESS = "0x887aD23913A2579f9B57f6D0a71D87C14EA2EF40";

async function main() {
  const count = parseInt(process.env.COUNT) || 5;
  const interval = parseInt(process.env.INTERVAL) || 3000;
  
  console.log(`🚀 Iniciando mint em massa de ${count} NFTs...`);
  console.log(`⏱️  Intervalo: ${interval/1000} segundos`);
  console.log(`📍 Contrato: ${CONTRACT_ADDRESS}`);
  console.log('');
  
  const contract = await hre.ethers.getContractAt("CosmicEvolvingNFT", CONTRACT_ADDRESS);
  const results = [];
  
  for (let i = 0; i < count; i++) {
    try {
      console.log(`🎨 Mintando NFT ${i + 1}/${count}...`);
      
      const tx = await contract.mintEntity({ gasLimit: 500000 });
      console.log(`⏳ Transação enviada: ${tx.hash}`);
      
      const receipt = await tx.wait();
      console.log(`✅ NFT criado! Block: ${receipt.blockNumber}`);
      
      results.push({
        index: i + 1,
        txHash: tx.hash,
        blockNumber: receipt.blockNumber,
        timestamp: new Date().toISOString()
      });
      
      if (i < count - 1) {
        console.log(`⏳ Aguardando ${interval/1000}s...`);
        await new Promise(resolve => setTimeout(resolve, interval));
      }
    } catch (error) {
      console.error(`❌ Erro no mint ${i + 1}:`, error.message);
      results.push({
        index: i + 1,
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }
  }
  
  console.log('');
  console.log('📊 RESUMO:');
  console.log(`✅ Sucessos: ${results.filter(r => !r.error).length}`);
  console.log(`❌ Erros: ${results.filter(r => r.error).length}`);
  console.log('');
  
  // Salvar resultados
  const logFile = `mint-log-${Date.now()}.json`;
  fs.writeFileSync(logFile, JSON.stringify(results, null, 2));
  console.log(`💾 Log salvo em: ${logFile}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
