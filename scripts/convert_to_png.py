#!/usr/bin/env python3
"""
Converte todos os SVGs da pasta nft-images para PNG em alta resolução
"""
import os
import sys
from pathlib import Path

try:
    import cairosvg
    USE_CAIRO = True
except ImportError:
    USE_CAIRO = False
    print("️  CairoSVG não instalado. Usando método alternativo...")
    print("Instale com: pip3 install cairosvg")

INPUT_DIR = Path("nft-images")
OUTPUT_DIR = Path("nft-images/png")
OUTPUT_DIR.mkdir(exist_ok=True)

def convert_with_cairosvg(svg_path, png_path, scale=4):
    """Converte usando CairoSVG (alta qualidade)"""
    cairosvg.svg2png(
        url=str(svg_path),
        write_to=str(png_path),
        output_width=1600,  # 4x o tamanho original (400px → 1600px)
        output_height=1600
    )

def convert_with_inkscape(svg_path, png_path):
    """Converte usando Inkscape"""
    import subprocess
    cmd = [
        "inkscape",
        str(svg_path),
        "--export-type=png",
        "--export-filename=" + str(png_path),
        "--export-width=1600",
        "--export-height=1600"
    ]
    subprocess.run(cmd, capture_output=True, text=True)

def main():
    if not INPUT_DIR.exists():
        print("❌ Pasta nft-images não encontrada!")
        return
    
    svg_files = list(INPUT_DIR.glob("*.svg"))
    
    if not svg_files:
        print("⚠️  Nenhum SVG encontrado. Exporte primeiro com: node scripts/export_svg.js all")
        return
    
    print(f"🎨 Convertendo {len(svg_files)} SVGs para PNG...
")
    
    for svg_path in sorted(svg_files):
        png_path = OUTPUT_DIR / svg_path.with_suffix('.png').name
        
        try:
            if USE_CAIRO:
                convert_with_cairosvg(svg_path, png_path)
            else:
                convert_with_inkscape(svg_path, png_path)
            
            print(f"✅ {svg_path.name} → {png_path.name}")
        except Exception as e:
            print(f" Erro ao converter {svg_path.name}: {e}")
    
    print(f"
✨ Conversão completa! PNGs salvos em: {OUTPUT_DIR}")
    print(f"📂 Para abrir: xdg-open {OUTPUT_DIR}")

if __name__ == "__main__":
    main()
