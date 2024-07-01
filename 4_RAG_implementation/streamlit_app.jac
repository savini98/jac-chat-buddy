import:py random;
import:py from mtllm.llms, OpenAI, Ollama, Huggingface;
import:py streamlit as st;
import:py from PIL, Image;
include:jac rag;

glob llm1 = OpenAI(model_name='gpt-3.5-turbo');
glob llm2 = OpenAI(model_name='gpt-4');
# glob llm2 = Ollama(model_name='phi3', verbose=True); # llama3-chatqa

# glob llm = Huggingface(model_name='nvidia/Llama3-ChatQA-1.5-8B');

glob RagEngine:rag_engine = rag_engine();

enum PR_states {
    init_PR = 'initial run',
    chat_create = 'create chat graph',
    chat = 'chat with user'
}

glob state = PR_states.init_PR;

'''
User node has user_name attribute.
'''
node user{
    has user_name:string="user";
}

'''
Chat session of a user. This node contains the session_id, user_data and todo_list.
This should also include the chat history. Can have multiple chat sessions.
'''
node session{
    has session_id : string = 100;
    has user_data : dict = {}; # User data such as habits, heart rate etc.
    has todo_list : list = []; # List of things to do by the user.
    has messages : list = []; # Chat history of the user.
}

'''
Consists of user data such as age, pressure, married status.
'''
node data{
    has user_data:dict = {
                "age" : 0,
                "Pressure" : (0,0),
                "Married" : False
                };
}

'''
List of things to do by the user.
'''
node todo{
    has todo_list:list = [];
}


'''
This is the chat walker which will be used to chat with the user.
The create_session ability:
    - gather the user data and todo list from connected nodes using filters.
    - Creates a new session with the user data and todo list.
    - Spawns the chat session with the session id.
'''
walker chat{
    can create_session with user entry;
}

'''
This is where we create the graph.
'''
walker create_graph{
    has user_data:dict = {};
    has todo_list:list = [];

    can generate_graph with `root entry;
}

'''
This is the query walker which will be used to query a user input and generate a response.
The init_query_engine ability:
    - Gathers the user data and todo list from the user node.
    - Asks the user for the routing method.
    - Creates a router node and connects it to the RAG_chat, todo_chat and user_qa_chat nodes.
    - Visits the router node.
'''
walker query{
    has query:str = '';
    has user_session_id:str='';
    has session_chat_history:list=[];
    has user_data: 'data about the health status of the user' :dict={};
    has todo_list: 'The tasks to be done by the user in the future.' :list=[];
    has messages:list = [];

    can init_query_engine with session entry;
}

enum task_type {
    RAG_TYPE : 'Need to use Retrivable information in specific medical articles' = "RAG",
    QA_TYPE : 'Need to use given user information' = "user_qa",
    TODO_TYPE : 'Need to use the todo list of the user' = "todo"
}

glob router_examples: 'Examples of routing of a query': dict[str, task_type] = {
    'When is my next check up?': task_type.TODO_TYPE,
    'How healthy am I?': task_type.QA_TYPE,
    'What are the symptoms of low blood pressure?': task_type.RAG_TYPE
};

'''
This is the router node which will be used to route the user query to the appropriate chat node.
'''
node router {
    can route with query entry;
    can 'route the query to the appropriate task type'
    router_with_llm(query:'Query from the user to be routed.':str,
                    todo_list:'The tasks to be done by the user in the future.':list,
                    user_data:'data about the health status of the user.':dict) -> task_type
                                        by llm2(method="Reason", temperature=0.0, incl_info=(router_examples));
}

'''
This is the RAG chat node which will be used to chat with the user using Retrival Augmented Generation.
TODO:Not yet implemented.
'''
node RAG_chat {
    can run_RAG with query entry;
    can 'You are a warmly Health Assistant named JacCare. Give a response based on the query using todo list. and user data'
    chat_llm(todo_list:'The tasks to be done by the user in the future.':list,
             user_data:'data about the health status of the user.':dict,
             query:'Question from the user to be answered.':str,
             retrived_context : 'Retrived information from expert articles':list,
             chat_history:'Previous Conversation with the user':list) -> 'response':str by llm2(temperature =0.8);
}

'''
This is the TODO chat node which will be used to chat with the user using the todo list and user data.
'''
node todo_chat {
    can run_todo with query entry;
    can 'You are a warmly Health Assistant named JacCare. Give a response based on the query using todo list. and user data'
    chat_llm(todo_list:'The tasks to be done by the user in the future.':list,
             user_data:'data about the health status of the user.':dict,
             query:'Question from the user to be answered.':str,
             chat_history:'Previous Conversation with the user':list) -> 'response':str by llm2(temperature =0.8);
}

'''
This is the user QA chat node which will be used to chat with the user using the user data.
TODO:Not yet implemented.
'''
node user_qa_chat {
    can run_user_qa with query entry;
    can 'You are a warmly Health Assistant named JacCare. Give a response based on the query using user data'
    chat_llm(user_data:'data about the health status of the user.':dict,
             query:'Question form the user.':str,
             chat_history:'Previous Conversation with the user':list) -> 'response':str by llm2(temperature =0.8);
}

walker save_data{
    has messages:list = [];
    can go_to_router with todo_chat | user_qa_chat | RAG_chat entry {
        visit [<--];
    }

    can go_to_session with router entry {
        visit [<--];
    }
    can save_data with session entry {
        here.messages = self.messages;
        disengage;
    }
}

can main() {
    :g: state;
    :g: RagEngine;

    st.set_page_config(
                    page_title="JacCare Health Assistant",
                    page_icon=":robot:",
                    layout="wide");
    # (left_co, cent_co,last_co) = st.columns(3);
    # with cent_co {
    # st.image(Image.open("images/JacCare LOGO.png"));
    # st.title("${\Large JacCare}$");
    # }

    st.image(Image.open("images/JacCare LOGO.png"));
    st.title("Jac${Care}$");

    if state == PR_states.init_PR {
        create_graph(   user_data = {
                                    "First_name": "David",
                                    "age_years": 45,
                                    "Gender": "Male",
                                    "Height_cm": 175,
                                    "Weight_kg": 85,
                                    "BMI": 27.8,
                                    "Blood_Pressure_mmHg": (145, 90),
                                    "Married": True,
                                    "Smoking_Status": "Former",
                                    "Alcohol_Intake": "Moderate",
                                    "Physical_Activity_Level": "Low",
                                    "Cholesterol_Level_mg_dL": 240,
                                    "HDL_mg_dL": 40,
                                    "LDL_mg_dL": 160,
                                    "Triglycerides_mg_dL": 200,
                                    "Blood_Glucose_mg_dL": 180,
                                    "HbA1c_percent": 8.0,
                                    "Medications": ["Metformin", "Atorvastatin"],
                                    "Family_History": {
                                        "Diabetes": True,
                                        "Heart_Disease": True,
                                        "Stroke": False
                                    },
                                    "Allergies": ["Penicillin"],
                                    "Regular_Checkups": True,
                                    "Last_Checkup_Date": "2024-05-10"
                                },

                        todo_list = [
                                    "Monitor blood pressure daily : 04/06/2024",
                                    "Take medication (Metformin, Atorvastatin) : 05/06/2024",
                                    "Schedule cardiology appointment : 10/06/2024",
                                    "Complete blood tests : 15/06/2024",
                                    "Attend diabetes education class : 20/06/2024",
                                    "Follow up with dietitian : 25/06/2024",
                                    "Exercise (30 minutes walk) : 26/06/2024",
                                    "Annual physical checkup : 01/07/2024",
                                    "Renew prescription for medications : 02/07/2024",
                                    "Check cholesterol levels : 05/07/2024",
                                    "Plan weekend getaway : 28/06/2024"
                                ]) spawn root;
    print('Graph created');
    state = PR_states.chat_create;
    query() spawn [[root -->](`?user)[0] -->](`?session)[0];
    } elif state == PR_states.chat_create {
        query() spawn [[root -->](`?user)[0] -->](`?session)[0];
        print('Chatting with user');
    } else {
        print('Invalid state');
    }

}

## Implementations ==================================================================================================================

:walker:chat:can:create_session {

        # Telescope into the nodes connected to the user node without walking.
        data_node = [-->](`?data)[0]; # Getting the data node filtered. can use [0] as having only one such node.
        todo_node = [-->](`?todo)[0]; # Getting the todo node filtered. can use [0] as having only one such node.
        new_session_id = str(random.randint(1,100));

        # Creating a new session node with the user data and todo list and connect it to the user.
        n = here ++> session(   session_id = new_session_id,
                            user_data = data_node.user_data,
                            todo_list = todo_node.todo_list
                        );
        visit n;
    }

:walker:chat:can:chat_session {
    # print(here.user_data);
    # print(here.todo_list);
    query() spawn here;
}

:walker:create_graph:can:generate_graph {
    end = here; # Assign the current root node (here) to end
    end ++> (end := user()); # Create a user node and connect it to the end node. Assign the new user node to the end.
    end ++> data(user_data = self.user_data); # Create a data node with the user data and connect it to the end node.
    end ++> todo(todo_list = self.todo_list); # Create a todo node with the todo list and connect it to the end node.
    chat() spawn [-->](`?user)[0]; # Spawn the chat walker with the user node.
}

:walker:query:can:init_query_engine {
    self.user_data:dict = here.user_data;
    self.todo_list:list = here.todo_list;
    self.messages:list = here.messages;

    for message in self.messages {
        with st.chat_message(message["role"]) {
            st.markdown(message["content"]);
        }
    }

        # To input a new query

    if [here -->] == [] {
        end = here;
        end ++> (end := router());
        end ++> RAG_chat();
        end ++> todo_chat();
        end ++> user_qa_chat();
    }

    if prompt := st.chat_input("What is up?") {
        self.query = prompt;
        self.messages.append({"role": "user", "content": self.query});
        with st.chat_message("user"){
            st.markdown(self.query);
        }
    visit [-->];
    }
}

:node:router:can:route {
    print('route');
    task:task_type = self.router_with_llm(query = here.query, todo_list = here.todo_list, user_data = here.user_data);
    print(task, type(task));
    if task == task_type.RAG_TYPE {
        visit [-->](`?RAG_chat);
    }
    if task == task_type.QA_TYPE | task == None {
        visit [-->](`?user_qa_chat);
    } elif task == task_type.TODO_TYPE {
        visit [-->](`?todo_chat);
    }
}

:node:todo_chat:can:run_todo {
    print('routed --> TODO');

    with st.chat_message("assistant"){
        response = self.chat_llm(
            todo_list=here.todo_list,
            user_data=here.user_data,
            query=here.query,
            chat_history=here.messages
        );
        stream = st.write(response);
    }

    here.messages.append({"role": "assistant", "content": response});
    save_data(messages = here.messages) spawn here;
}

:node:user_qa_chat:can:run_user_qa {
    print('routed --> USER_QA');

    with st.chat_message("assistant"){
        response = self.chat_llm(
            user_data=here.user_data,
            query=here.query,
            chat_history=here.messages
        );
        stream = st.write(response);
    }

    here.messages.append({"role": "assistant", "content": response});
    save_data(messages = here.messages) spawn here;
}

:node:RAG_chat:can:run_RAG {
    print('routed --> RAG');

    with st.chat_message("assistant"){
        response = self.chat_llm(
            todo_list=here.todo_list,
            user_data=here.user_data,
            query=here.query,
            chat_history=here.messages,
            retrived_context=RagEngine.get_from_chroma(query=here.query)
        );
        stream = st.write(response);
    }

    here.messages.append({"role": "assistant", "content": response});
    save_data(messages = here.messages) spawn here;
}