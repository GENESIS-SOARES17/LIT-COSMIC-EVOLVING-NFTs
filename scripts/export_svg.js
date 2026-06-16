const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

const CONTRACT_ADDRESS = "NOVO_ENDEREÇO_AQUI";

function decodeBase64(str) {
  return Buffer.from(str, 'base64').toString('utf-8');
}

async function exportNFT(tokenId) {
  console.log(`📦 Exporting NFT #${tokenId}...`);
  
  const contract = await hre.ethers.getContractAt("CosmicEvolvingNFT", CONTRACT_ADDRESS);
  const tokenURI = await contract.tokenURI(tokenId);
  
  const base64Data = tokenURI.replace('data:application/json;base64,', '');
  const jsonStr = decodeBase64(base64Data);
  const metadata = JSON.parse(jsonStr);
  
  const imageData = metadata.image.replace('data:image/svg+xml;base64,', '');
  const svgContent = decodeBase64(imageData);
  
  const outputPath = path.join(__dirname, '..', 'nft-images', `cosmic_nft_${tokenId}.svg`);
  fs.writeFileSync(outputPath, svgContent);
  
  console.log(`✅ Saved to: ${outputPath}`);
  console.log(`🎨 Entity: ${metadata.name}`);
}

async function main() {
  const arg = process.argv[2];
  
  if (!arg) {
    console.log("Usage: node scripts/export_svg.js <tokenId|all>");
    process.exit(1);
  }
  
  if (arg === 'all') {
    const contract = await hre.ethers.getContractAt("CosmicEvolvingNFT", CONTRACT_ADDRESS);
    const nextId = await contract.nextTokenId();
    
    for (let i = 1; i < nextId; i++) {
      try {
        await exportNFT(i);
      } catch (e) {
        console.log(`⚠️  Skipping NFT #${i}: ${e.message}`);
      }
    }
  } else {
    await exportNFT(parseInt(arg));
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
