// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CosmicEvolvingNFT is ERC721, Ownable {
    uint256 public nextTokenId;
    uint256 public totalFusions;
    
    // 25 formas geométricas (0-13: 2D, 14-24: 3D)
    // 0: Triângulo, 1: Quadrado, 2: Retângulo, 3: Círculo, 4: Losango,
    // 5: Trapézio, 6: Paralelogramo, 7: Pentágono, 8: Hexágono, 9: Heptágono,
    // 10: Octógono, 11: Decágono, 12: Dodecágono, 13: Elipse,
    // 14: Cubo, 15: Esfera, 16: Cilindro, 17: Cone, 18: Pirâmide,
    // 19: Prisma Triangular, 20: Paralelepípedo, 21: Tetraedro, 22: Octaedro,
    // 23: Dodecaedro, 24: Icosaedro
    
    struct EntityDNA {
        uint256 seed;
        uint256 generation;
        uint256 parent1;
        uint256 parent2;
        bool isMutant;
        uint8 shapeType;      // 0-24
        uint8 colorIndex;     // 0-49
        uint8 rotation;       // 0-359
        uint8 size;           // 50-150
    }
    
    mapping(uint256 => EntityDNA) public entityDNA;
    
    event EntityBorn(uint256 indexed tokenId, uint256 seed, uint256 generation);
    event EntityFused(uint256 indexed newTokenId, uint256 parent1, uint256 parent2, bool isMutant);
    
    // 50 cores em hex
    string[50] public colorPalette = [
        "#DC143C", // 0: Vermelho Carmim
        "#FF2400", // 1: Vermelho Escarlate
        "#E2725B", // 2: Terracota
        "#FF00FF", // 3: Magenta
        "#FF6EC7", // 4: Rosa Choque
        "#FFB6C1", // 5: Rosa Bebê
        "#FA8072", // 6: Salmão
        "#FF7F50", // 7: Coral
        "#FFBF00", // 8: Âmbar
        "#FFEF00", // 9: Amarelo Canário
        "#E1AD01", // 10: Amarelo Mostarda
        "#FF9933", // 11: Laranja Cenoura
        "#FFFDD0", // 12: Creme/Marfim
        "#FFD700", // 13: Ouro/Dourado
        "#50C878", // 14: Verde Esmeralda
        "#808000", // 15: Verde Oliva
        "#8A9A5B", // 16: Verde Musgo
        "#98FF98", // 17: Verde Menta
        "#4B5320", // 18: Verde Militar
        "#BFFF00", // 19: Verde Lima
        "#00FFFF", // 20: Ciano/Verde-Água
        "#000080", // 21: Azul Marinho
        "#0047AB", // 22: Azul Cobalto
        "#40E0D0", // 23: Azul Turquesa
        "#89CFF0", // 24: Azul Bebê/Celeste
        "#005F69", // 25: Azul Petróleo
        "#4B0082", // 26: Azul Índigo/Anil
        "#4169E1", // 27: Azul Royal
        "#8B00FF", // 28: Roxo/Violeta
        "#E6E6FA", // 29: Lavanda/Lilás
        "#800080", // 30: Púrpura
        "#301934", // 31: Berinjela
        "#DA70D6", // 32: Orquídea
        "#7B3F00", // 33: Marrom Chocolate
        "#F5F5DC", // 34: Bege
        "#C3B091", // 35: Cáqui
        "#FFD59A", // 36: Caramelo
        "#704214", // 37: Sépia
        "#CD7F32", // 38: Bronze
        "#FFFFFF", // 39: Branco Neve
        "#FAF9F6", // 40: Off-White
        "#C0C0C0", // 41: Cinza Claro/Prata
        "#464646", // 42: Cinza Chumbo
        "#000000", // 43: Preto Absoluto
        "#383838", // 44: Grafite
        "#722F37", // 45: Vinho/Bordô
        "#E3BC9A", // 46: Nude
        "#FF00FF", // 47: Fúcsia
        "#008080", // 48: Turmalina
        "#F3E5AB"  // 49: Amarelo Baunilha
    ];
    
    constructor() ERC721("Cosmic Geometric NFT", "CGNFT") Ownable(msg.sender) {
        nextTokenId = 1;
    }
    
    function mintEntity() external returns (uint256) {
        uint256 tokenId = nextTokenId++;
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, tokenId, msg.sender, block.prevrandao)));
        
        uint8 shapeType = uint8(seed % 25);
        uint8 colorIndex = uint8((seed >> 8) % 50);
        uint8 rotation = uint8((seed >> 16) % 360);
        uint8 size = uint8(50 + ((seed >> 24) % 101));
        
        entityDNA[tokenId] = EntityDNA({
            seed: seed,
            generation: 1,
            parent1: 0,
            parent2: 0,
            isMutant: false,
            shapeType: shapeType,
            colorIndex: colorIndex,
            rotation: rotation,
            size: size
        });
        
        _safeMint(msg.sender, tokenId);
        emit EntityBorn(tokenId, seed, 1);
        
        return tokenId;
    }
    
    function fuseNFTs(uint256 tokenId1, uint256 tokenId2) external returns (uint256) {
        require(ownerOf(tokenId1) == msg.sender, "Not owner of token 1");
        require(ownerOf(tokenId2) == msg.sender, "Not owner of token 2");
        require(tokenId1 != tokenId2, "Cannot fuse same token");
        
        EntityDNA memory dna1 = entityDNA[tokenId1];
        EntityDNA memory dna2 = entityDNA[tokenId2];
        
        uint256 newSeed = uint256(keccak256(abi.encodePacked(dna1.seed, dna2.seed, block.timestamp, block.prevrandao)));
        
        // 10% chance de mutação
        bool isMutant = (uint256(keccak256(abi.encodePacked(newSeed, "mutation"))) % 100) < 10;
        
        // Herança: média das formas (com variação)
        uint8 newShapeType = uint8((uint16(dna1.shapeType) + uint16(dna2.shapeType)) / 2);
        if (newShapeType > 24) newShapeType = 24;
        
        // Variação aleatória na forma
        uint8 variation = uint8(newSeed % 5);
        if (variation > 2) {
            newShapeType = uint8(uint16(newShapeType) + variation - 2);
            if (newShapeType > 24) newShapeType = 24;
        }
        
        // Herança: média das cores
        uint8 newColorIndex = uint8((uint16(dna1.colorIndex) + uint16(dna2.colorIndex)) / 2);
        
        // Variação na cor
        uint8 colorVar = uint8((newSeed >> 8) % 7);
        if (colorVar > 3) {
            newColorIndex = uint8(uint16(newColorIndex) + colorVar - 3);
            if (newColorIndex > 49) newColorIndex = 49;
        }
        
        // Mutantes têm cor especial (Magenta ou Fúcsia)
        if (isMutant) {
            newColorIndex = uint8(newSeed % 2 == 0 ? 3 : 47); // Magenta ou Fúcsia
        }
        
        // Herança: média de rotação e tamanho
        uint8 newRotation = uint8((uint16(dna1.rotation) + uint16(dna2.rotation)) / 2);
        uint8 newSize = uint8((uint16(dna1.size) + uint16(dna2.size)) / 2);
        
        // Nova geração
        uint256 newGeneration = dna1.generation > dna2.generation ? dna1.generation + 1 : dna2.generation + 1;
        
        uint256 newTokenId = nextTokenId++;
        totalFusions++;
        
        entityDNA[newTokenId] = EntityDNA({
            seed: newSeed,
            generation: newGeneration,
            parent1: tokenId1,
            parent2: tokenId2,
            isMutant: isMutant,
            shapeType: newShapeType,
            colorIndex: newColorIndex,
            rotation: newRotation,
            size: newSize
        });
        
        _safeMint(msg.sender, newTokenId);
        emit EntityFused(newTokenId, tokenId1, tokenId2, isMutant);
        emit EntityBorn(newTokenId, newSeed, newGeneration);
        
        return newTokenId;
    }
    
    function getColorHex(uint8 colorIndex) public view returns (string memory) {
        require(colorIndex < 50, "Invalid color index");
        return colorPalette[colorIndex];
    }
    
    function getShapeName(uint8 shapeType) public pure returns (string memory) {
        string[25] memory names = [
            "Triangulo", "Quadrado", "Retangulo", "Circulo", "Losango",
            "Trapezio", "Paralelogramo", "Pentagono", "Hexagono", "Heptagono",
            "Octogono", "Decagono", "Dodecagono", "Elipse",
            "Cubo", "Esfera", "Cilindro", "Cone", "Piramide",
            "Prisma Triangular", "Paralelepipedo", "Tetraedro", "Octaedro",
            "Dodecaedro", "Icosaedro"
        ];
        require(shapeType < 25, "Invalid shape type");
        return names[shapeType];
    }
}
