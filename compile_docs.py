#!/usr/bin/env python3
import os
import re
from pathlib import Path

def preprocess_docs(docs_dir, output_file):
    docs_path = Path(docs_dir)
    compiled_content = []
    
    # 1. Find all markdown files sorted alphabetically to keep order logical
    md_files = sorted(list(docs_path.glob("**/*.md")))
    
    print(f"Found {len(md_files)} markdown files. Preprocessing...")
    
    for file_path in md_files:
        rel_path = file_path.relative_to(docs_path)
        
        if any(part.startswith('.') or part in ['node_modules', 'venv'] for part in rel_path.parts):
            continue
            
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
            
        # ── CLEANING PIPELINE ──
        # Fix: Robust front-matter strip that handles windows line endings and whitespaces
        content = re.sub(r'^\s*---\s*\n(.*?)\n---\s*\n', '', content, flags=re.DOTALL | re.MULTILINE)
        
        content = re.sub(r'▲ Back to top.*', '', content, flags=re.IGNORECASE)
        content = re.sub(r'\n{3,}', '\n\n', content)
        
        doc_id = str(rel_path).replace('.md', '').replace('/', ':')
        
        compiled_content.append(f'<document id="{doc_id}" path="{rel_path}">\n')
        compiled_content.append(f'# File: {rel_path}\n\n')
        compiled_content.append(content.strip())
        compiled_content.append('\n</document>\n\n')
        
    with open(output_file, 'w', encoding='utf-8') as out:
        out.write("# QUICKSHELL FRAMEWORK DOCUMENTATION COMPILATION\n")
        out.write("This file contains the complete consolidated documentation for Quickshell.\n")
        out.write("Each documentation file is encapsulated within a `<document>` XML tag.\n\n")
        out.write(''.join(compiled_content))
        
    print(f"Successfully compiled documentation into: {output_file}")

if __name__ == "__main__":
    docs_directory = "../Desktop/projects/quickshell-docs"
    output_master_file = "quickshell_compiled_docs.md"
    
    if os.path.exists(docs_directory):
        preprocess_docs(docs_directory, output_master_file)
    else:
        print(f"Error: Directory '{docs_directory}' not found. Please verify the path.")
