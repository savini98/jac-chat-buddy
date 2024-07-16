## Assignment 2 - Preface

In today's world, having our health assistant chatbot that can engage in meaningful back-and-forth conversations is incredibly valuable. The best way to achieve this is by leveraging a Large Language Model (LLM). 

Here's a demonstration of how an LLM can be utilized to build a simple chatbot that responds to a user's query:
1. **User Sends a Query**: The interaction starts with the user typing a question or statement related to their health.

2. **LLM Processes the Query**: The chatbot, powered by an LLM, receives the query and processes it to understand the user's intent and context. This involves natural language understanding capabilities inherent in the LLM.

3. **Generate and Send Response**: The LLM generates a response that is coherent and relevant to the user's query. This response is then sent back to the user, continuing the conversation.

To realize this in JacLang, we have the ```by llm``` feature. Install the MTLLM package by,

    ```bash
    pip install mtllm
    ```

Get more details on this feature by visiting JacLang [documentation.](https://www.jac-lang.org/learn/with_llm/)

[This](/2_basic_chatbot_jac_llm.jac) is a basic chatbot implementation using JacLang to respond for a single query. 


## Assignment 2 - Task

Build a chatbot that can respond to multiple chained queries on the command line interface.

### Should Include
1. Chat History Management.
2. Using the ```by llm()``` feature in jac-lang.
3. Able to maintain a continuing chat.
4. Chat-bot should be implemented for ```todo``` and ```user_QA``` nodes. (not for ```RAG```)

    - **In ```todo```**: should use both user data as well as the todo list to answer queries.
    - **In ```user_QA```**: should use only user data to answer queries.

