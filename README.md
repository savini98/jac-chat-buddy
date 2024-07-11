# Developing a next-gen Chatbot in Jac
> Assignment - AI Lecture Series

In this multipart assignment series we will be developing a chatbot which is capable of generating domain specific as well as user specific responses.

## Problem Definition

The status quo chatbots in the current market use Large Language Models to answer user queries. However, LLMs seems to hallucinate and misinterpret information due to less context awareness and the lack of recent information about the topic. This has become a problem for many chatbots which are purposefully built to answer domain specific queries.

## Final Goal

The final goal of this assignment is to build a chatbot which can use available specific information and user data to answer queries much accurately, in jaclang. For these assignments, assume there is only user quarriying about health and medical questions.

- A chat-bot that uses three different techniques when answering health related queries.
  1. Use Retrieval Augmented Generation with a repository of expert articles on health and medicine.
  2. Use user-data to generate a more personalized answer.
  3. Give recommendations based on the medical To-do data of the patient.

The query from the user should be routed to its specific type based upon the context offered in the query.

### [Assignment 1 - Building chatbot architecture in Jaclang](/Assignmnet%20Docs/Assignment_1.md)
### [Assignment 2 - Building a basic chatbot](/Assignmnet%20Docs/Assignment_2.md)
### [Assignment 3 - Develop a streamlit frontend for the chatbot](/Assignmnet%20Docs/Assignment_3.md)
### [Assignment 3.2 - Develop a streamlit frontend for the chatbot](/Assignmnet%20Docs/Assignment_3_2.md)
### [Assignment 4 - RAG implementation](/Assignmnet%20Docs/Assignment_4.md)
