import tiktoken

def count_tokens(text: str, model: str = "text-embedding-3-large") -> int:
    encoding = tiktoken.encoding_for_model(model)
    return len(encoding.encode(text))

system_prompt = open("./project_docs/cobebase_str.txt", "r", encoding="utf-8").read()
print("Tokens:", count_tokens(system_prompt))