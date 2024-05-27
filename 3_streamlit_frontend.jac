import:py streamlit as st;

import:py from jaclang.core.llms, Groq;

glob llm = Groq();

can 'Continue the chat in a conversational mannor.'
answer_query(messages: 'chat history including the newest message' : list[dict[str, str]]) -> 'response to the final query':str
    by llm(temperature=0.7, max_tokens=1024);

glob messages = [];

can main {
    st.title("ChatGPT-like clone");

    for message in messages{
        with st.chat_message(message["role"]){
            st.markdown(message["content"]);
        }
    }

    if prompt := st.chat_input("What is up?") {
    messages.append({"role": "user", "content": prompt});
    with st.chat_message("user"){
        st.markdown(prompt);
    }

    with st.chat_message("assistant"){
        response = answer_query(messages=[
                {"role": m["role"], "content": m["content"]}
                for m in messages
            ]);
        stream = st.write(response);
    }

    messages.append({"role": "assistant", "content": response});
    }
}