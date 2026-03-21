import re
from typing import List, Dict, Any

class MigrationEngine:
    def __init__(self, rules: List[Dict[str, Any]]):
        self.rules = rules

    def apply_rules(self, content: str) -> str:
        for rule in self.rules:
            rule_type = rule.get("type")
            target = rule.get("target")
            replacement = rule.get("replacement")

            if not target or replacement is None:
                continue

            if rule_type == "replace":
                content = content.replace(target, replacement)
            elif rule_type == "regex":
                try:
                    # Support multiline regex and $1 notation (converted to \1)
                    # We use re.sub which uses \1, \2 etc.
                    # Mapping $N to \N for convenience if needed, but let's stick to Python standard or map it.
                    python_replacement = replacement.replace("$", "\\")
                    content = re.sub(target, python_replacement, content, flags=re.MULTILINE)
                except re.error as e:
                    print(f"Error in regex rule '{target}': {e}")
            
        return content
