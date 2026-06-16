#!/bin/bash
echo "=== Monitoramento Cosmic NFTs ==="
echo "Data: $(date)"
echo ""
echo "Últimos 5 mints:"
tail -20 bot.log | grep "Entity #"
echo ""
echo "Total de NFTs na pasta:"
ls nft-images/*.svg 2>/dev/null | wc -l
