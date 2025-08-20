import os
from langchain_core.tools import tool
from langchain_core.callbacks.base import BaseCallbackHandler

PROJECT = "./project_files/"

@tool
def write_file(file_path: str, text: str) -> str:
    """Write text into a file (overwrite if exists)."""
    try:
        real_file_path = os.path.join(PROJECT, file_path)
        with open(real_file_path, "w", encoding="utf-8") as f:
            f.write(text)
        return f"✅ File written: {file_path}"
    except Exception as e:
        return f"❌ Error writing file {file_path}: {e}"

@tool
def read_file(file_path: str) -> str:
    """Read text content from a file."""
    try:
        real_file_path = os.path.join(PROJECT, file_path)
        with open(real_file_path, "r", encoding="utf-8") as f:
            return f.read()
    except Exception as e:
        return f"❌ Error reading file {file_path}: {e}"

@tool
def file_delete(file_path: str) -> str:
    """Delete a file."""
    try:
        real_file_path = os.path.join(PROJECT, file_path)
        os.remove(real_file_path)
        return f"✅ File deleted: {file_path}"
    except Exception as e:
        return f"❌ Error deleting file {file_path}: {e}"

@tool
def create_directory(dir_path: str) -> str:
    """Create a directory (including parent dirs if missing)."""
    try:
        real_dir_path = os.path.join(PROJECT, dir_path)
        os.makedirs(real_dir_path, exist_ok=True)
        return f"✅ Directory created: {dir_path}"
    except Exception as e:
        return f"❌ Error creating directory {dir_path}: {e}"

@tool
def list_directory(dir_path: str) -> str:
    """List all files and directories inside a directory."""
    try:
        real_dir_path = os.path.join(PROJECT, dir_path)
        items = os.listdir(real_dir_path)
        return "\n".join(items) if items else "(empty directory)"
    except Exception as e:
        return f"❌ Error listing directory {dir_path}: {e}"