const { ethers } = require("ethers");
require("dotenv").config();

const CONTRACT_ADDRESS = "NOVO_ENDEREÇO_AQUI";
const RPC_URL = process.env.LITEFORGE_RPC_URL || "https://liteforge.rpc.caldera.xyz/http";
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const ABI = [
  "function mintEntity() external returns (uint256)",
  "function nextTokenId() external view returns (uint256)",
  "function getEntityInfo(uint256) external view returns (uint256,uint256,uint256,string,string)",
  "function getCosmicState() external view returns (uint256,uint256,string,uint256)"
];

function randomDelay(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

async function mintWithBot() {
  try {
    const provider = new ethers.JsonRpcProvider(RPC_URL);
    const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
    const contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, wallet);
    
    console.log(`\n🤖 Bot running | Wallet: ${wallet.address.slice(0, 6)}...${wallet.address.slice(-4)}`);
    
    const cosmicState = await contract.getCosmicState();
    console.log(`🌌 Phase: ${cosmicState[2]} | Total: ${cosmicState[1].toString()}`);
    
    console.log("🎨 Minting...");
    const tx = await contract.mintEntity();
    console.log(`⏳ TX: ${tx.hash}`);
    
    const receipt = await tx.wait();
    console.log("✅ Confirmed!");
    
    const nextId = await contract.nextTokenId();
    const tokenId = Number(nextId) - 1;
    
    const info = await contract.getEntityInfo(tokenId);
    console.log(`🌟 Entity #${tokenId}: ${info[3]} (${info[4]})`);
    
  } catch (error) {
    console.error("❌ Error:", error.message);
  }
}

async function runBot() {
  console.log("🚀 Starting Cosmic NFT Bot...");
  console.log("📅 Will mint 5 entities per day\n");
  
  let mintsToday = 0;
  const maxMintsPerDay = 5;
  
  async function scheduleNextMint() {
    if (mintsToday >= maxMintsPerDay) {
      console.log(`\n⏰ Daily limit reached.`);
      setTimeout(() => {
        mintsToday = 0;
        scheduleNextMint();
      }, 24 * 60 * 60 * 1000);
      return;
    }
    
    const delay = randomDelay(30, 300);
    console.log(`⏱️  Next mint in ${delay} seconds...`);
    
    setTimeout(async () => {
      await mintWithBot();
      mintsToday++;
      console.log(`📊 Mints today: ${mintsToday}/${maxMintsPerDay}`);
      scheduleNextMint();
    }, delay * 1000);
  }
  
  await mintWithBot();
  mintsToday++;
  scheduleNextMint();
}

runBot().catch(console.error);
