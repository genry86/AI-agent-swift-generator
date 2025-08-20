from pydantic import BaseModel, Field, field_validator, model_validator
from typing import Optional, List, Literal, Union, Type, Any
import re
import config

class File(BaseModel):
    """
    Information about swift file.
    All string properties MUST be valid JSON string.
    All special characters inside string properties MUST be escaped with double-backslash.
    """
    name: str = Field(..., description="The name of the file with `.swift` extension")
    code: str = Field(..., description="Swift code content as valid, compatible JSON string. Backslashes must be double-escaped")

    # @field_validator("code", mode="before")
    # def normalize_code(cls, v):
    #     if not isinstance(v, str):
    #         v = str(v)
    #
    #     # 1. Normalize common control characters
    #     replacements = {
    #         "\r\n": "\n",  # Windows newlines → Unix
    #         "\r": "\n",  # old Mac → Unix
    #         "\t": "    ",  # tabs → spaces
    #         "\u00A0": " ",  # non-breaking space → normal space
    #         "\u200B": "",  # zero-width space → remove
    #         "\u202F": " ",  # narrow no-break space → normal space
    #         "\uFEFF": "",  # BOM → remove
    #     }
    #     for bad, good in replacements.items():
    #         v = v.replace(bad, good)
    #
    #     # 2. Escape backslashes (make them double-escaped)
    #     # turns "\" → "\\"
    #     v = v.replace("\\", "\\\\")
    #
    #     # 3. Optionally escape quotes (if JSON-sensitive)
    #     v = v.replace('"', '\\"')
    #
    #     # 4. Collapse weird control characters into spaces
    #     v = re.sub(r"[\x00-\x08\x0B\x0C\x0E-\x1F]", " ", v)
    #
    #     return v

class Folder(BaseModel):
    """Information about any folder of the app. May have other subfolders and inner files."""
    name: str = Field(..., description="The name of the folder")
    folders: List["Folder"] = Field(default_factory=list, description="Subfolders inside the current folder")
    files: List[File] = Field(default_factory=list, description="Files inside the current folder")

class AppSchema(BaseModel):
    """Root folder of the app."""
    folders: List["Folder"] = Field(default_factory=list, description="Subfolders inside the root folder")
    files: List[File] = Field(default_factory=list, description="Files inside the root folder")

    @model_validator(mode="after")
    def check_non_empty(self):
        if len(self.folders) == 0 and len(self.files) == 0:
            raise ValueError("AppSchema must contain at least one folder or one file")
        return self