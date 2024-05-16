import:py from jaclang.core.llms, Anthropic;

glob llm = Anthropic(model_name="claude-3-sonnet-20240229");

can 'Translate English Representation to the given language'
translate(input: str, lang: str = "French")
-> str by llm();

with entry {
    print(translate("I am a student", "French"));
    print(translate("I am a student", "Language used in Somalia"));
}