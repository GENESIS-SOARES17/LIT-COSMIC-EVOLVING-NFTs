// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CosmicEvolvingNFT is ERC721, Ownable {
    uint256 public nextTokenId;
    uint256 public totalFusions;
    
    struct EntityDNA {
        uint256 seed;
        uint256 generation;
        uint256 parent1;
        uint256 parent2;
        bool isMutant;
    }
    
    mapping(uint256 => EntityDNA) public entityDNA;
    
    event EntityBorn(uint256 indexed tokenId, uint256 seed, uint256 generation);
    event EntityFused(uint256 indexed newTokenId, uint256 parent1, uint256 parent2, bool isMutant);
    
    constructor() ERC721("Cosmic NFT", "CNFT") Ownable(msg.sender) {
        nextTokenId = 1;
    }
    
    function mintEntity() external returns (uint256) {
        uint256 tokenId = nextTokenId++;
        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, tokenId, msg.sender, block.prevrandao)));
        
        entityDNA[tokenId] = EntityDNA({
            seed: seed,
            generation: 1,
            parent1: 0,
            parent2: 0,
            isMutant: false
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
        
        uint256 newSeed = uint256(keccak256(abi.encodePacked(
            dna1.seed, 
            dna2.seed, 
            block.timestamp, 
            block.prevrandao
        )));
        
        bool isMutant = (uint256(keccak256(abi.encodePacked(newSeed, "mutation"))) % 100) < 10;
        
        uint256 newGeneration = dna1.generation > dna2.generation 
            ? dna1.generation + 1 
            : dna2.generation + 1;
        
        uint256 newTokenId = nextTokenId++;
        totalFusions++;
        
        entityDNA[newTokenId] = EntityDNA({
            seed: newSeed,
            generation: newGeneration,
            parent1: tokenId1,
            parent2: tokenId2,
            isMutant: isMutant
        });
        
        _safeMint(msg.sender, newTokenId);
        emit EntityFused(newTokenId, tokenId1, tokenId2, isMutant);
        emit EntityBorn(newTokenId, newSeed, newGeneration);
        
        return newTokenId;
    }
    
    function getEntityInfo(uint256 tokenId) external view returns (
        uint256 seed,
        uint256 generation,
        uint256 parent1,
        uint256 parent2,
        bool isMutant
    ) {
        require(_ownerOf(tokenId) != address(0), "Entity does not exist");
        EntityDNA memory dna = entityDNA[tokenId];
        return (dna.seed, dna.generation, dna.parent1, dna.parent2, dna.isMutant);
    }
}
