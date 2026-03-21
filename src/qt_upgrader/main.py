import argparse
import os
import json5
from pathlib import Path
from .engine import MigrationEngine

def load_rules(rules_path: str):
    with open(rules_path, "r", encoding="utf-8") as f:
        return json5.load(f)

def process_file(file_path: Path, engine: MigrationEngine, dry_run: bool):
    try:
        content = file_path.read_text(encoding="utf-8")
        new_content = engine.apply_rules(content)
        
        if content != new_content:
            if dry_run:
                print(f"[DRY-RUN] Would modify: {file_path}")
            else:
                print(f"Modifying: {file_path}")
                file_path.write_text(new_content, encoding="utf-8")
        else:
            # print(f"No changes for: {file_path}")
            pass
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

def main():
    parser = argparse.ArgumentParser(description="Qt5 to Qt6 Migration Toolkit")
    parser.add_argument("path", help="File or directory to upgrade")
    parser.add_argument("--rules", help="Path to custom rules JSON5 file")
    parser.add_argument("--dry-run", action="store_true", help="Don't apply changes, just show what would be done")
    parser.add_argument("--extensions", default=".py,.cpp,.h", help="Comma-separated list of extensions to process")
    
    args = parser.parse_args()
    
    # Resolve default rules if not provided
    rules_path = args.rules
    if not rules_path:
        base_dir = Path(__file__).parent
        rules_path = base_dir / "rules" / "qt5_to_qt6.json5"
    
    if not os.path.exists(rules_path):
        print(f"Error: Rules file not found at {rules_path}")
        return

    rules_data = load_rules(rules_path)
    engine = MigrationEngine(rules_data.get("rules", []))
    
    target_path = Path(args.path)
    extensions = tuple(args.extensions.split(","))
    
    if target_path.is_file():
        process_file(target_path, engine, args.dry_run)
    elif target_path.is_dir():
        for root, dirs, files in os.walk(target_path):
            for file in files:
                if file.endswith(extensions):
                    process_file(Path(root) / file, engine, args.dry_run)
    else:
        print(f"Error: Path {target_path} does not exist")

if __name__ == "__main__":
    main()
