
        // ===== ÁRVORE GENEALÓGICA COMPLETA =====
        let treeData = [];
        let expandedNodes = new Set();

        async function loadTree() {
            const container = document.getElementById('treeVisualization');
            container.innerHTML = '<div class="loading"><div class="spinner"></div>Carregando árvore genealógica...</div>';
            
            try {
                const nextId = await contract.nextTokenId();
                const total = Number(nextId) - 1;
                
                if (total === 0) {
                    container.innerHTML = '<div class="loading">Nenhum NFT criado ainda.</div>';
                    return;
                }
                
                // Buscar todos os NFTs
                const entities = [];
                for (let i = 1; i < nextId; i++) {
                    try {
                        const dna = await contract.entityDNA(i);
                        const seed = dna[0];
                        entities.push({
                            id: i,
                            generation: Number(dna[1]),
                            parent1: Number(dna[2]),
                            parent2: Number(dna[3]),
                            isMutant: dna[4],
                            shapeType: getShapeTypeFromSeed(seed),
                            colorIndex: getColorIndexFromSeed(seed)
                        });
                    } catch (e) {
                        console.error(`Erro NFT #${i}:`, e);
                    }
                }
                
                // Construir árvore
                treeData = buildTree(entities);
                expandedNodes = new Set(treeData.filter(n => n.generation <= 2).map(n => n.id));
                
                renderTree();
                
            } catch (e) {
                console.error("Erro ao carregar árvore:", e);
                container.innerHTML = '<div class="loading">Erro ao carregar árvore</div>';
            }
        }

        function buildTree(entities) {
            const nodeMap = new Map();
            const roots = [];
            
            // Criar mapa de nós
            entities.forEach(entity => {
                nodeMap.set(entity.id, {
                    ...entity,
                    children: [],
                    expanded: entity.generation <= 2
                });
            });
            
            // Construir hierarquia
            entities.forEach(entity => {
                const node = nodeMap.get(entity.id);
                
                if (entity.parent1 === 0 && entity.parent2 === 0) {
                    // NFT fundador (sem pais)
                    roots.push(node);
                } else {
                    // Adicionar como filho dos pais
                    if (entity.parent1 > 0 && nodeMap.has(entity.parent1)) {
                        nodeMap.get(entity.parent1).children.push(node);
                    }
                    if (entity.parent2 > 0 && entity.parent2 !== entity.parent1 && nodeMap.has(entity.parent2)) {
                        nodeMap.get(entity.parent2).children.push(node);
                    }
                }
            });
            
            return roots;
        }

        function renderTree() {
            const container = document.getElementById('treeVisualization');
            container.innerHTML = '';
            
            const treeContainer = document.createElement('div');
            treeContainer.className = 'tree-container';
            treeContainer.style.cssText = `
                overflow-x: auto;
                padding: 40px 20px;
                min-height: 400px;
            `;
            
            const treeContent = document.createElement('div');
            treeContent.className = 'tree-content';
            treeContent.style.cssText = `
                display: flex;
                flex-direction: column;
                align-items: center;
                gap: 40px;
                min-width: max-content;
            `;
            
            // Renderizar por geração
            const maxGen = Math.max(...treeData.flatMap(n => getDescendants(n).map(d => d.generation)));
            
            for (let gen = 1; gen <= maxGen; gen++) {
                const genNodes = getNodesByGeneration(treeData, gen);
                
                const genContainer = document.createElement('div');
                genContainer.className = 'generation-container';
                genContainer.style.cssText = `
                    display: flex;
                    gap: 20px;
                    justify-content: center;
                    align-items: flex-start;
                `;
                
                genNodes.forEach(node => {
                    const nodeEl = createTreeNode(node);
                    genContainer.appendChild(nodeEl);
                });
                
                treeContent.appendChild(genContainer);
            }
            
            treeContainer.appendChild(treeContent);
            container.appendChild(treeContainer);
        }

        function getNodesByGeneration(roots, generation) {
            const result = [];
            roots.forEach(root => {
                const nodes = getDescendants(root);
                result.push(...nodes.filter(n => n.generation === generation));
            });
            return result;
        }

        function getDescendants(node) {
            const result = [node];
            node.children.forEach(child => {
                result.push(...getDescendants(child));
            });
            return result;
        }

        function createTreeNode(node) {
            const nodeEl = document.createElement('div');
            nodeEl.className = 'tree-node';
            nodeEl.style.cssText = `
                background: var(--glass-bg);
                border: 2px solid ${node.isMutant ? 'var(--primary)' : 'var(--glass-border)'};
                border-radius: 15px;
                padding: 15px;
                min-width: 180px;
                cursor: pointer;
                transition: all 0.3s;
                position: relative;
            `;
            
            nodeEl.onmouseover = () => {
                nodeEl.style.transform = 'scale(1.05)';
                nodeEl.style.boxShadow = '0 10px 30px rgba(0, 255, 255, 0.3)';
            };
            nodeEl.onmouseout = () => {
                nodeEl.style.transform = 'scale(1)';
                nodeEl.style.boxShadow = 'none';
            };
            
            const color = colorPalette[node.colorIndex];
            const shape = shapeNames[node.shapeType];
            
            nodeEl.innerHTML = `
                <div style="display:flex;align-items:center;justify-content:center;margin-bottom:10px;">
                    <div style="width:60px;height:60px;background:${color};border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:2em;">
                        ${getNodeIcon(node.shapeType)}
                    </div>
                </div>
                <div style="text-align:center;">
                    <div style="font-weight:bold;margin-bottom:5px;">NFT #${node.id}</div>
                    <div style="font-size:0.85em;opacity:0.8;">${shape}</div>
                    <div style="font-size:0.8em;opacity:0.6;margin-top:5px;">
                        Gen ${node.generation}
                        ${node.isMutant ? '<span style="color:var(--primary);font-weight:bold;"> 🧬 MUTANTE</span>' : ''}
                    </div>
                    ${node.children.length > 0 ? `<div style="font-size:0.75em;opacity:0.7;margin-top:5px;">👶 ${node.children.length} filho(s)</div>` : ''}
                </div>
                ${node.children.length > 0 ? `
                    <button onclick="toggleNode(${node.id})" style="
                        position:absolute;
                        bottom:-15px;
                        left:50%;
                        transform:translateX(-50%);
                        background:var(--secondary);
                        border:none;
                        border-radius:50%;
                        width:30px;
                        height:30px;
                        cursor:pointer;
                        font-size:1.2em;
                        display:flex;
                        align-items:center;
                        justify-content:center;
                    ">${expandedNodes.has(node.id) ? '−' : '+'}</button>
                ` : ''}
            `;
            
            // Esconder filhos se não expandido
            if (node.children.length > 0 && !expandedNodes.has(node.id)) {
                node.children.forEach(child => {
                    const childEl = document.querySelector(`[data-node-id="${child.id}"]`);
                    if (childEl) childEl.style.display = 'none';
                });
            }
            
            return nodeEl;
        }

        function getNodeIcon(shapeType) {
            const icons = ['🔺', '⬜', '▭', '', '💎', '🔷', '▱', '', '', '⬢', '⯃', '', '', '⬭', '📦', '🔮', '🥫', '🔺', '🔼', '🔺', '📦', '🔷', '⯁', '⯂', '⯃'];
            return icons[shapeType] || '🔷';
        }

        function toggleNode(nodeId) {
            if (expandedNodes.has(nodeId)) {
                expandedNodes.delete(nodeId);
            } else {
                expandedNodes.add(nodeId);
            }
            renderTree();
        }

        // Adicionar estilos CSS
        const style = document.createElement('style');
        style.textContent = `
            .tree-container::-webkit-scrollbar {
                height: 10px;
            }
            .tree-container::-webkit-scrollbar-track {
                background: rgba(255, 255, 255, 0.1);
                border-radius: 10px;
            }
            .tree-container::-webkit-scrollbar-thumb {
                background: linear-gradient(90deg, var(--primary), var(--secondary));
                border-radius: 10px;
            }
            .tree-node {
                animation: fadeIn 0.5s ease;
            }
            @keyframes fadeIn {
                from { opacity: 0; transform: translateY(-20px); }
                to { opacity: 1; transform: translateY(0); }
            }
        `;
        document.head.appendChild(style);
