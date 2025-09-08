import json
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

from config import CONTEXT_WINDOW, REACT_ITERATIONS, RETRY_NUMBER, TEMPERATURE
from schemas import AppSchema
from tools_utility import write_file, read_file, file_delete, create_directory, list_directory
from utility import runnable, fetch_file, fetch_prompt, create_agent_prompt, chain_save_data, to_dict, to_agent_input, fetch_context, fetch_prompt_str

load_dotenv()

if __name__ == '__main__':
    APP_DESCRIPTION = ("Create Macos app, implemented on SwiftUI, MVVM, Combine. App should be similar to browser."
                       "Left sidebar should have bookmarks list which opens webpage. Right sidebar should have list of attached notes, text or images.")

    # --- Tools ---
    tools = [write_file, read_file, file_delete, create_directory, list_directory]
    tools_description = render_text_description(tools)

    # --- LLM Model ---
    # - Production model -
    # llm = init_chat_model("gpt-4.1", model_provider="openai", temperature=0)
    # - Debug local model -
    llm = ChatOllama(model="gpt-oss:120b", validate_model_on_init=True, temperature=TEMPERATURE, num_ctx=CONTEXT_WINDOW)
    llm_tools = llm.bind_tools(tools)

    # --- Agent configuration ---
    memory = MemorySaver()
    config: RunnableConfig = {
        "configurable": {"thread_id": "ai-code-generator-1"},
        "recursion_limit": REACT_ITERATIONS
    }

    # --- Json Schema of generating App structure ---
    codebase_schema = AppSchema.model_json_schema()

    # --- Context data ---
    context = fetch_context("context")
    basic_rules = fetch_context("basic_rules_str")
    user_rules = fetch_context("user_rules_str")
    deprecated_code = fetch_context("swiftui_deprecated_str")

    # --- Prompts ---
    prompt_generate_structured_description = fetch_prompt("1-level-structured-description").partial(context=context)
    prompt_generate_technical_description = fetch_prompt("2-level-technical-features").partial(context=context)
    prompt_generate_navigation = fetch_prompt("3-level-navigation").partial(context=context)
    prompt_generate_codebase = fetch_prompt("4-level-code-generation").partial(
        context=context,
        basic_rules=basic_rules,
        user_rules=user_rules,
        deprecated_code=deprecated_code,
        codebase_schema=codebase_schema
    )

    # Create ReAct Agent
    # agent_prompt = create_agent_prompt(system_prompt)
    agent_prompt = fetch_prompt_str("system_prompt").format(
        codebase_schema=codebase_schema,
        tools=tools_description
    )

    # --- Agent ---
    agent_executor = create_react_agent(llm_tools, tools, checkpointer=memory, prompt=agent_prompt).with_retry(stop_after_attempt=RETRY_NUMBER)

    # --- Main app description ---
    query = ("Create Macos app, implemented on SwiftUI, MVVM, Combine. App should be similar to browser. "
             "Left sidebar should have bookmarks list which opens webpage. Right sidebar should have list of attached notes, text or images.")

    # --- Pre-processing chains ---
    # 1 - Create structured project data based on App description
    chain_generate_structured_description = (prompt_generate_structured_description
                                             | llm
                                             | StrOutputParser()
                                             | chain_save_data("1_structured_description"))

    # 2 - Create technical description, based on data from previous steps
    chain_generate_technical_description = (prompt_generate_technical_description
                                         | llm
                                         | StrOutputParser()
                                         | chain_save_data("2_technical_description"))

    # 3 - Create navigation description, based on data from previous steps
    chain_generate_navigation = (prompt_generate_navigation
                                 | llm
                                 | StrOutputParser()
                                 | chain_save_data("3_navigation"))

    # 4 - Generate Folder, files structure based on all generated previously data
    pydantic_parser = PydanticOutputParser(pydantic_object=AppSchema)
    safe_pydantic_parser = OutputFixingParser.from_llm(parser=pydantic_parser, llm=llm).with_retry(stop_after_attempt=RETRY_NUMBER)
    chain_generate_codebase = (prompt_generate_codebase
                                 | llm
                                 | safe_pydantic_parser
                                 | to_dict
                                 | chain_save_data("4_codebase"))

    # --- Debug chains with existing values ---
    # chain_generate_structured_description = runnable(fetch_file("./project_docs/1_structured_description.txt"))
    # chain_generate_technical_description = runnable(fetch_file("./project_docs/2_technical_description.txt"))
    # chain_generate_navigation = runnable(fetch_file("./project_docs/3_navigation.txt"))
    # chain_generate_codebase = runnable(fetch_file("./project_docs/4_codebase.txt"))

    # --- Combine 4 pre-processing chains before Agent start ---
    chain_create_context_data = (
        RunnablePassthrough()
            .assign(structured_description=chain_generate_structured_description)
            .assign(technical_description=chain_generate_technical_description)
            .assign(navigation=chain_generate_navigation)
        | chain_generate_codebase
    )

    # Main pipeline:
    # ---
    # 1. get context data
    # 2. convert/prepare data
    # 3. rela files, folders generation (via Agent)
    # ---
    pipeline = chain_create_context_data | to_agent_input | agent_executor

    # --- Start Pipeline ---
    response = pipeline.invoke({ "app_description": APP_DESCRIPTION }, config)
    for message in response["messages"]:
        message.pretty_print()