import json
import os
from dotenv import load_dotenv

from pydantic import BaseModel
from typing import Optional, List, Literal, Union, Type, Any
from operator import itemgetter

from langchain.chat_models import init_chat_model
from langchain.output_parsers import OutputFixingParser
from langchain_core.messages import HumanMessage, SystemMessage, AIMessage
from langchain_core.output_parsers import PydanticOutputParser, StrOutputParser, JsonOutputParser
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder, SystemMessagePromptTemplate, PromptTemplate
from langchain_core.runnables import RunnablePassthrough, RunnableLambda, RunnableParallel
from langchain_core.runnables import RunnableConfig, chain, Runnable
from langchain_community.agent_toolkits import FileManagementToolkit
from langgraph.checkpoint.memory import MemorySaver
from langgraph.prebuilt import create_react_agent
from langchain_core.tools import tool
from langchain.tools.render import render_text_description
from langchain_ollama import ChatOllama
import re

from config import PROMPTS_PATH, CONTEXT_PATH, PROJECT_DOCS

def runnable(content: str) -> RunnableLambda:
    return RunnableLambda(lambda _: content)

@chain
def to_agent_input(content):
    if isinstance(content, dict):
        content = json.dumps(content, ensure_ascii=False, indent=2)
    return {"messages": [
        {"role": "user", "content": content}
    ]}

@chain
def to_dict(m: BaseModel):
    """ Return dictionary from Pydantic model """
    return m.model_dump()

def create_agent_prompt(prompt):
    system_prompt = SystemMessagePromptTemplate(prompt=prompt)
    agent_prompt = ChatPromptTemplate.from_messages([
        system_prompt,
        MessagesPlaceholder("messages"),
    ])
    return agent_prompt

def fetch_context(filename: str) -> str:
    full_path = os.path.join(CONTEXT_PATH, f"{filename}.txt")
    with (open(full_path, "r", encoding="utf8") as file):
        content = file.read().replace("{", "{{").replace("}", "}}")
        return content

def fetch_file(filename: str) -> str:
    with (open(filename, "r", encoding="utf8") as file):
        content = file.read().replace("{", "{{").replace("}", "}}")
        return content

def fetch_prompt(filename: str, is_chat_prompt = True):
    full_path = os.path.join(PROMPTS_PATH, f"{filename}.txt")
    with open(full_path, "r", encoding="utf8") as file:
        content = file.read()
        prompt = ChatPromptTemplate.from_template(content) if is_chat_prompt else PromptTemplate.from_template(content)
        return prompt

@chain
def save_data(data):
    full_path = os.path.join(PROJECT_DOCS, f"{data['filename']}.txt")
    with open(full_path, "w") as file:
        content = data["input"]
        if isinstance(content, dict):
            content = json.dumps(content, ensure_ascii=False, indent=2)
        if isinstance(content, (AIMessage, HumanMessage, SystemMessage)):
            content = str(content.content)
        content = normalize_spaces(content)
        file.write(content)
    return data["input"]

def chain_save_data(filename) -> Runnable:
    return (
        RunnableParallel({"input": RunnablePassthrough(), "filename": runnable(filename) })
        | save_data
    )

def normalize_spaces(obj):
    """ Remove special characters from string. """
    if isinstance(obj, dict):
        return {k: normalize_spaces(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [normalize_spaces(v) for v in obj]
    elif isinstance(obj, str):
        return obj.replace(" ", " ").replace(" ", " ")
    else:
        return obj