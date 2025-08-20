#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import json
from pathlib import Path

def load_json(path: Path):
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)

def join_title_content(items):
    return "\n\n".join(
        f"{it.get('title','').strip()}\n{it.get('content','').strip()}"
        for it in items if it.get("title") or it.get("content")
    )

def join_deprecated(items):
    return "\n\n".join(
        f"{it.get('breadcrumbs','').strip()}\n"
        # f"{it.get('description','').strip()}\n"
        f"deprecated-code - `{it.get('deprecated-code','').strip()}`\n"
        f"{it.get('alternative-code','').strip()}"
        for it in items
        if any(it.get(k) for k in ["breadcrumbs", "deprecated-code", "alternative-code"])
        # if any(it.get(k) for k in ["breadcrumbs", "description", "deprecated-code", "alternative-code"])
    )

def main():
    base_path = Path("./context_data")

    basic_rules = load_json(base_path / "basic_rules.json")
    user_rules = load_json(base_path / "user_rules.json")
    swiftui_deprecated = load_json(base_path / "swiftui_deprecated.json")

    basic_rules_str = join_title_content(basic_rules)
    user_rules_str = join_title_content(user_rules)
    swiftui_deprecated_str = join_deprecated(swiftui_deprecated)

    print("=== basic_rules_str ===")
    print(basic_rules_str[:1000], "...\n")
    print("=== user_rules_str ===")
    print(user_rules_str[:1000], "...\n")
    print("=== swiftui_deprecated_str ===")
    print(swiftui_deprecated_str[:1000], "...\n")

    (base_path / "basic_rules_str.txt").write_text(basic_rules_str, encoding="utf-8")
    (base_path / "user_rules_str.txt").write_text(user_rules_str, encoding="utf-8")
    (base_path / "swiftui_deprecated_str.txt").write_text(swiftui_deprecated_str, encoding="utf-8")

if __name__ == "__main__":
    main()