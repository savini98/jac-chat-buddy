import:py random;
import:py openai;

'''
User node has user_name attribute.
'''
node user{
    has user_name:string="user";
}

walker query {
    #can go_to_router with session entry;
    has session_id : string = 100;
    has user_data : dict = {}; # User data such as habits, heart rate etc.
    has todo_list : list = []; # List of things to do by the user.
    has inquiry_by_user: string = ''; 

}
'''
Chat session of a user. This node contains the session_id, user_data and todo_list.
This should also include the chat history. Can have multiple chat sessions.
'''
node session{
    has session_id : string = 100;
    has user_data : dict = {}; # User data such as habits, heart rate etc.
    has todo_list : list = []; # List of things to do by the user.
    can send_query_to_router with query entry;
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
    can chat_session with session entry;
}

'''
This is where we create the graph.
'''
walker create_graph{
    has user_data:dict = {};
    has todo_list:list = [];
    can generate_graph with `root entry;
}

node router {
    can direct with query entry;
}
node RAG {
    can print_output with query entry;
}

node user_QA{
    can print_output with query entry;
}
node user_TODO{
    can print_output with query entry;
}


:node:RAG:can:print_output{
    print("At RAG");
    visit [<--];
}

:node:user_QA:can:print_output{
    print("At QA");
    visit [<--];
}
:node:user_TODO:can:print_output{
    print("At TODO");
    visit [<--];
}
:node:session:can:send_query_to_router{
    print(31242434524234);
    if here.session_id == self.session_id{
        here.inquiry_by_user = input('What is the routing method : ');
        if here.inquiry_by_user != "x"{
        visit [-->];
        }
    }
    else{
    here.session_id = self.session_id;
    here.user_data =self.user_data;
    here.todo_list = self.todo_list;
    here.inquiry_by_user = input('What is the routing method : ');
    end = self;
    end ++> (end := router());
    end ++> RAG();
    end ++> user_QA();
    end ++> user_TODO();
    visit [-->];
    
    }
    #grthde
    
}
:node:router:can:direct{
    print(here.inquiry_by_user );
    end = self;
    if here.inquiry_by_user == "RAG" {
        
        here.inquiry_by_user = '';
        visit [-->](`?RAG);
    }
    elif here.inquiry_by_user == "QA" {
        
        here.inquiry_by_user = '';
        visit [-->](`?user_QA);
    }elif here.inquiry_by_user == "RAG" {
        
        here.inquiry_by_user = '';
        visit [-->](`?user_TODO);
    }else
    {
        visit [<--];
    }    
}

:walker:create_graph:can:generate_graph{
    end = here; # Assign the current root node (here) to end
    end ++> (end := user()); # Create a user node and connect it to the end node. Assign the new user node to the end.
    end ++> data(user_data = self.user_data); # Create a data node with the user data and connect it to the end node.
    end ++> todo(todo_list = self.todo_list); # Create a todo node with the todo list and connect it to the end node.
    chat() spawn [-->](`?user)[0]; # Spawn the chat walker with the user node.
}

:walker:chat:can:create_session{

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
:walker:chat:can:chat_session{
        print(here.user_data);
        print(here.todo_list);
        query() spawn here; #[-->](`?router);
        
}


with entry {
    create_graph(   user_data={ "age": 20,
                                "Pressure": (120, 80),
                                "Married": False
                            },
                     todo_list=["Do heart surgery",
                                "Buy Bread",
                                "Have pizza for dinner"]
                ) spawn root;
}
