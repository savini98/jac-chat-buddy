import:py streamlit as st;

import:py from jaclang.core.llms, Ollama;

glob llm = Ollama();
glob item = 2;

glob messages: "Previous Chat History with the Chatbot"
                :list = [];

can 'You are a chatbot : Respond to the new query using chat history in a conversational manner as an ai assistant'
answer_query(
        query:'New user Query':str,
        messages:'Previous Chat History with the Chatbot':str
        ) -> 'Response':str by llm();

can main {
    st.title("ChatGPT Clone");

    for message in messages {
        with st.chat_message(message["role"]) {
            st.markdown(message["content"]);
        }
    }

    if prompt := st.chat_input("Ask away") {
        messages.append({"role":"user","content":prompt});
        response = answer_query(query=prompt, messages=messages);
        messages.append({"role":"ai","content":response});
        with st.chat_message("user") {
            st.markdown(prompt);
        }
        st.write(response);
    }
  
    
}