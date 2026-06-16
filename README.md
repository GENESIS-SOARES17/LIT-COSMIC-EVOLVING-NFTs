# Cosmic Evolving NFTs - LitVM

NFTs evolutivos na rede LitVM LiteForge com sistema de fusão e árvore genealógica.

## Características
- NFTs Evolutivos com DNA único
- Sistema de Fusão (combine 2 NFTs)
- Árvore Genealógica (pais → filhos → netos)
- 10% chance de NFT Mutante raro
- Herança Visual (cores herdadas dos pais)

## Contrato
- Endereço: 0x578c1650AB432801839D385A54EAae4f4d7a7A7C
- Rede: LitVM LiteForge (Chain ID: 4441)
- Explorer: https://liteforge.explorer.caldera.xyz/address/0x578c1650AB432801839D385A54EAae4f4d7a7A7C

## Instalação
npm install
npx hardhat compile
npx hardhat run scripts/deploy.js --network liteforge

## Uso
- Mint: npx hardhat run scripts/mint.js --network liteforge
- Fusão: TOKEN1=1 TOKEN2=2 npx hardhat run scripts/fuse.js --network liteforge
- Frontend: python3 -m http.server 8080
