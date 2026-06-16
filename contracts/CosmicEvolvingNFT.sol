// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CosmicEvolvingNFT is ERC721URIStorage, Ownable {
    uint256 public nextTokenId;
    uint256 public totalFusions;
    
    struct EntityDNA {
        uint256 seed;
        uint256 generation;
        uint256 parent1;
        uint256 parent2;
        bool isMutant;
        uint256 colorR;
        uint256 colorG;
        uint256 colorB;
        uint256 shapeType;
    }
    
    mapping(uint256 => EntityDNA) public entityDNA;
    
    event EntityBorn(uint256 indexed tokenId, uint256 seed, uint256 generation);
    event EntityFused(uint256 indexed newTokenId, uint256 parent1, uint256 parent2, bool isMutant);
    
    constructor() ERC721("Cosmic Evolving NFT", "CNFT") Ownable(msg.sender) {
        nextTokenId = 1;
    }
    
    function mintEntity() external returns (uint256) {
        uint256 tokenId = nextTokenId++;
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, tokenId, msg.sender, block.prevrandao)));
        
        // Gerar cores aleatórias para Geração 1
        uint256 r = (seed >> 192) & 0xFF;
        uint256 g = (seed >> 128) & 0xFF;
        uint256 b = (seed >> 64) & 0xFF;
        uint256 shape = seed % 5;
        
        entityDNA[tokenId] = EntityDNA({
            seed: seed,
            generation: 1,
            parent1: 0,
            parent2: 0,
            isMutant: false,
            colorR: r,
            colorG: g,
            colorB: b,
            shapeType: shape
        });
        
        _safeMint(msg.sender, tokenId);
        
        string memory uri = generateTokenURI(tokenId);
        _setTokenURI(tokenId, uri);
        
        emit EntityBorn(tokenId, seed, 1);
        return tokenId;
    }
    
    function fuseNFTs(uint256 tokenId1, uint256 tokenId2) external returns (uint256) {
        require(ownerOf(tokenId1) == msg.sender, "Not owner of token 1");
        require(ownerOf(tokenId2) == msg.sender, "Not owner of token 2");
        require(tokenId1 != tokenId2, "Cannot fuse same token");
        
        EntityDNA memory dna1 = entityDNA[tokenId1];
        EntityDNA memory dna2 = entityDNA[tokenId2];
        
        // Combinar DNA
        uint256 newSeed = uint256(keccak256(abi.encodePacked(dna1.seed, dna2.seed, block.timestamp, block.prevrandao)));
        
        // 10% chance de mutação
        bool isMutant = (uint256(keccak256(abi.encodePacked(newSeed, "mutation"))) % 100) < 10;
        
        // Herdar cores dos pais (média com variação)
        uint256 newR = (dna1.colorR + dna2.colorR) / 2;
        uint256 newG = (dna1.colorG + dna2.colorG) / 2;
        uint256 newB = (dna1.colorB + dna2.colorB) / 2;
        
        // Variação aleatória nas cores (+/- 20)
        uint256 variation = newSeed % 41;
        if (variation > 20) {
            newR = (newR + variation - 20) % 256;
            newG = (newG + variation - 20) % 256;
            newB = (newB + variation - 20) % 256;
        } else {
            newR = newR > (20 - variation) ? newR - (20 - variation) : 0;
            newG = newG > (20 - variation) ? newG - (20 - variation) : 0;
            newB = newB > (20 - variation) ? newB - (20 - variation) : 0;
        }
        
        // Mutantes têm cores vibrantes
        if (isMutant) {
            newR = (newR + 100) % 256;
            newG = (newG + 100) % 256;
            newB = (newB + 100) % 256;
        }
        
        // Forma evolui com geração
        uint256 newGeneration = dna1.generation > dna2.generation ? dna1.generation + 1 : dna2.generation + 1;
        uint256 newShape = (dna1.shapeType + dna2.shapeType + newGeneration) % 5;
        
        // Queimar pais
        _burn(tokenId1);
        _burn(tokenId2);
        
        // Criar filho
        uint256 newTokenId = nextTokenId++;
        totalFusions++;
        
        entityDNA[newTokenId] = EntityDNA({
            seed: newSeed,
            generation: newGeneration,
            parent1: tokenId1,
            parent2: tokenId2,
            isMutant: isMutant,
            colorR: newR,
            colorG: newG,
            colorB: newB,
            shapeType: newShape
        });
        
        _safeMint(msg.sender, newTokenId);
        
        string memory uri = generateTokenURI(newTokenId);
        _setTokenURI(newTokenId, uri);
        
        emit EntityFused(newTokenId, tokenId1, tokenId2, isMutant);
        emit EntityBorn(newTokenId, newSeed, newGeneration);
        
        return newTokenId;
    }
    
    function generateTokenURI(uint256 tokenId) internal view returns (string memory) {
        EntityDNA memory dna = entityDNA[tokenId];
        string memory svg = generateSVG(dna);
        string memory json = generateJSON(tokenId, dna, svg);
        
        return string(abi.encodePacked(
            "data:application/json;base64,",
            base64Encode(bytes(json))
        ));
    }
    
    function generateSVG(EntityDNA memory dna) internal pure returns (string memory) {
        string memory color1 = toColor(dna.colorR, dna.colorG, dna.colorB);
        string memory color2 = toColor(
            (dna.colorR + 50) % 256,
            (dna.colorG + 50) % 256,
            (dna.colorB + 50) % 256
        );
        
        // Background baseado na geração
        string memory bg = dna.generation == 1 ? "#0a0a2e" : 
                          dna.generation == 2 ? "#1a0a2e" :
                          dna.generation == 3 ? "#2a0a2e" : "#3a0a2e";
        
        // Forma baseada no shapeType
        string memory shape = "";
        if (dna.shapeType == 0) {
            shape = string(abi.encodePacked(
                '<circle cx="200" cy="200" r="100" fill="', color1, '" opacity="0.8"/>',
                '<circle cx="200" cy="200" r="60" fill="', color2, '" opacity="0.9"/>'
            ));
        } else if (dna.shapeType == 1) {
            shape = string(abi.encodePacked(
                '<polygon points="200,100 300,300 100,300" fill="', color1, '" opacity="0.8"/>',
                '<polygon points="200,150 260,270 140,270" fill="', color2, '" opacity="0.9"/>'
            ));
        } else if (dna.shapeType == 2) {
            shape = string(abi.encodePacked(
                '<rect x="120" y="120" width="160" height="160" fill="', color1, '" opacity="0.8" rx="20"/>',
                '<rect x="150" y="150" width="100" height="100" fill="', color2, '" opacity="0.9" rx="10"/>'
            ));
        } else if (dna.shapeType == 3) {
            shape = string(abi.encodePacked(
                '<ellipse cx="200" cy="200" rx="120" ry="80" fill="', color1, '" opacity="0.8"/>',
                '<ellipse cx="200" cy="200" rx="80" ry="50" fill="', color2, '" opacity="0.9"/>'
            ));
        } else {
            shape = string(abi.encodePacked(
                '<path d="M200,100 L280,200 L200,300 L120,200 Z" fill="', color1, '" opacity="0.8"/>',
                '<path d="M200,140 L250,200 L200,260 L150,200 Z" fill="', color2, '" opacity="0.9"/>'
            ));
        }
        
        // Indicador de mutante
        string memory mutantBadge = "";
        if (dna.isMutant) {
            mutantBadge = '<circle cx="350" cy="50" r="30" fill="#ff00ff" opacity="0.8"/><text x="350" y="60" text-anchor="middle" fill="white" font-size="20" font-weight="bold">M</text>';
        }
        
        // Indicador de geração
        string memory genBadge = string(abi.encodePacked(
            '<circle cx="50" cy="50" r="25" fill="#00ffff" opacity="0.8"/>',
            '<text x="50" y="58" text-anchor="middle" fill="black" font-size="16" font-weight="bold">G', uint2str(dna.generation), '</text>'
        ));
        
        // Pais (se for fusão)
        string memory parentInfo = "";
        if (dna.parent1 > 0 && dna.parent2 > 0) {
            parentInfo = string(abi.encodePacked(
                '<text x="200" y="380" text-anchor="middle" fill="white" font-size="12" opacity="0.7">Parents: #', uint2str(dna.parent1), ' + #', uint2str(dna.parent2), '</text>'
            ));
        }
        
        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">',
            '<rect width="400" height="400" fill="', bg, '"/>',
            shape,
            mutantBadge,
            genBadge,
            parentInfo,
            '</svg>'
        ));
    }
    
    function generateJSON(uint256 tokenId, EntityDNA memory dna, string memory svg) internal pure returns (string memory) {
        string memory name = dna.isMutant ? "Mutant Cosmic" : "Cosmic Entity";
        
        return string(abi.encodePacked(
            '{"name":"', name, ' #', uint2str(tokenId), '",',
            '"description":"Generation ', uint2str(dna.generation), ' entity. DNA: ', uint2str(dna.seed), '",',
            '"image":"data:image/svg+xml;base64,', base64Encode(bytes(svg)), '",',
            '"attributes":[',
            '{"trait_type":"Generation","value":', uint2str(dna.generation), '},',
            '{"trait_type":"Shape","value":', uint2str(dna.shapeType), '},',
            '{"trait_type":"Mutant","value":"', dna.isMutant ? "Yes" : "No", '"},',
            '{"trait_type":"Color R","value":', uint2str(dna.colorR), '},',
            '{"trait_type":"Color G","value":', uint2str(dna.colorG), '},',
            '{"trait_type":"Color B","value":', uint2str(dna.colorB), '}',
            ']}'
        ));
    }
    
    function toColor(uint256 r, uint256 g, uint256 b) internal pure returns (string memory) {
        return string(abi.encodePacked("#", toHex(r), toHex(g), toHex(b)));
    }
    
    function toHex(uint256 value) internal pure returns (string memory) {
        bytes memory hexChars = "0123456789abcdef";
        bytes memory result = new bytes(2);
        result[0] = hexChars[(value >> 4) & 0x0f];
        result[1] = hexChars[value & 0x0f];
        return string(result);
    }
    
    function uint2str(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    
    function base64Encode(bytes memory data) internal pure returns (string memory) {
        bytes memory table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
        bytes memory padChar = "=";
        if (data.length == 0) return "";
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        bytes memory result = new bytes(encodedLen);
        uint256 i;
        uint256 j;
        for (i = 0; i < data.length; i += 3) {
            uint256 a = uint8(data[i]);
            uint256 b = i + 1 < data.length ? uint8(data[i + 1]) : 0;
            uint256 c = i + 2 < data.length ? uint8(data[i + 2]) : 0;
            uint256 triple = (a << 16) | (b << 8) | c;
            result[j++] = table[(triple >> 18) & 0x3F];
            result[j++] = table[(triple >> 12) & 0x3F];
            if (i + 1 < data.length) {
                result[j++] = table[(triple >> 6) & 0x3F];
            } else {
                result[j++] = padChar[0];
            }
            if (i + 2 < data.length) {
                result[j++] = table[triple & 0x3F];
            } else {
                result[j++] = padChar[0];
            }
        }
        return string(result);
    }
    
    function getEntityInfo(uint256 tokenId) external view returns (
        uint256 seed,
        uint256 generation,
        uint256 parent1,
        uint256 parent2,
        bool isMutant,
        uint256 colorR,
        uint256 colorG,
        uint256 colorB,
        uint256 shapeType
    ) {
        require(_ownerOf(tokenId) != address(0), "Entity does not exist");
        EntityDNA memory dna = entityDNA[tokenId];
        return (dna.seed, dna.generation, dna.parent1, dna.parent2, dna.isMutant, dna.colorR, dna.colorG, dna.colorB, dna.shapeType);
    }
}
