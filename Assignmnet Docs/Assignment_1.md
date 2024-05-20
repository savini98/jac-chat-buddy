## Assignment 1 - Preface

The data spatial implementation of the chatbot skeleton is expected to view as below.

<p align="center">
  <img src="https://github.com/savini98/jac-chat-buddy/blob/main/Images/DSP.png" alt="GitHub Logo" width="450">
</p>

### Graph Overview:

  #### Nodes & Edges:

- **user:** This chatbot supports multiple users. Each user has their own user node. Let’s consider single user for this assignment.

- **session:** This chatbot supports back-and-forth conversation. The chat history is managed in sessions. So each user might have many sessions. Each session represents one conversation between that user and the chatbot.

- **data:** A node that contains user's health data. It is a user specific data.

- **todo:** Similar to data node. This node contains another type of user specific data - their to-do list.

> **NOTE** :
>   The edges used so far in the graph are generic edges.

#### Walkers:

- **create_graph:** This walker creates the graph of chatbot skeleton shown in figure except the session node.

- **chat:** This walker creates the session node while gathering all the data and saving to the session node.

This is a [simple example](/1_chat_bot_graph_impl.jac) to create the graph of basic chatbot skeleton and the chat walker.


## Assignment 1 - Task

Build a ‘query’ walker which activates (spawns) on a session node.

<p align="center">
  <img src="https://github.com/savini98/jac-chat-buddy/blob/main/Images/Task_1.png" alt="GitHub Logo" width="450">
</p>

The walker should:
- Build the sub-graph shown in the diagram.

### Graph Overview
- **router :** gets a specific user input from user (‘RAG’, ‘QA’,’TODO’) and direct the walker to the correct functional node.

- **RAG :** This node will be implemented in coming weeks of the assignment. For now, when the query walker enters this node, it should print "I am RAG".

- **User_QA :** This node will be implemented in coming weeks of the assignment. For now, when the query walker enters this node, it should print "I will respond using user data." and the ```user_data``` gathered in the session node.

- **TODO nodes :** This node will be implemented in coming weeks of the assignment. For now, when the query walker enters this node, it should print "I will respond using user to-do list." and the ```todo``` gathered in the session node.

## Assignment 1 - Solution

This is the [solution](/1_solution.jac) for the Assignment 1 - Task.