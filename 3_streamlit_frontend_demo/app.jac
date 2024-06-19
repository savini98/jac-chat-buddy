import:py streamlit as st;

import:py from jaclang.core.llms, Ollama;

glob llm = Ollama(model_name = "phi3");

glob messages: "Previous Chat History with the Chatbot"
    :list = [];

can 'Respond to the new query using chat history in a conversational manner'
answer_query(
    query:'New user Query':str
    ) -> 'Response to the newest query':str by llm(incl_info=messages);

can main {
    st.title("Chat Buddy");

    for message in messages {
        with st.chat_message(message["role"]) {
            st.markdown(message["content"]);
        }
    }

    if prompt := st.chat_input("Ask away") {
        messages.append({"role":"user","content":prompt});
        response = answer_query(query=prompt);
        messages.append({"role":"ai","content":response});
        with st.chat_message("user") {
            st.markdown(prompt);
        }
        st.write(response);
    }
}
