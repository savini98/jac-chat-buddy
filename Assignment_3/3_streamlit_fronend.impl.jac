:node:RAG:can:print_output{
    #print("At RAG");
    here.inquiry_by_user = '';
    visit [<--];
}

:node:user_QA:can:print_output{
    #print("At QA");
    self.answer = self.chat_llm(user_data=here.user_data,query=here.inquiry_by_user);
    with st.chat_message("assistant"){
        stream = st.write(self.answer);
    }
    print(self.answer);
    here.user_query.append(self.answer);
    visit [<--];
}
:node:user_TODO:can:print_output{
    #print("At TODO");
    self.answer = self.chat_llm(todo_list=here.todo_list,query=here.inquiry_by_user);
    with st.chat_message("assistant"){
        stream = st.write(self.answer);
    }
    print(self.answer);
    here.user_query.append(self.answer);
    visit [<--];
    
}
:node:session:can:send_query_to_router{
    print("here");
    here.inquiry_by_user = st.chat_input("What is up?",key = self.session_id);
    if (here.inquiry_by_user) {
        if here.session_id == self.session_id{
            self.chat_history.append(here.user_query);
            here.user_query = [];  
            #here.inquiry_by_user = input('What else can I help you with : ');#st.chat_input("What is up?");#
        }
        else{
            here.session_id = self.session_id;
            here.user_data =self.user_data;
            here.todo_list = self.todo_list;
            here.inquiry_by_user = prompt;
            #here.inquiry_by_user = input('How can I help you : ');#st.chat_input("What is up?");#input('How can I help you : ');
            #here.user_query.append(here.inquiry_by_user);
            end = self;
            end ++> (end := router());
            end ++> RAG();
            end ++> user_QA();
            end ++> user_TODO();
            #visit [-->];
              
        } 
        #here.inquiry_by_user = prompt;
        here.user_query.append(here.inquiry_by_user);
        with st.chat_message("user"){
            st.markdown(here.inquiry_by_user);
        }
        if here.inquiry_by_user != "x"{
            visit [-->];
        }
        else{
            self.end_seesion();
        }  
    }  
}

:node:session:can:end_seesion{
    file = open(self.chat_file_name+str(self.session_id)+".txt", 'w');
    for i in self.chat_history{
        file.write(i[0]+":"+i[1] + '\n');
    }
    file.close();
}
:node:router:can:direct{
    if (len(here.user_query)<2)
    {
        self.match = re.search(r'(@\w+)\s(.*)', here.inquiry_by_user);
        if (self.match){
            #at_part = match.group(1)  # The @TODO part
            #remainder = match.group(2)  # The remainder of the string
            if self.match.group(1) == "@RAG" {        
                here.inquiry_by_user = self.match.group(2);
                visit [-->](`?RAG);
            }
            elif self.match.group(1) == "@QA" {
                
                here.inquiry_by_user = self.match.group(2);
                visit [-->](`?user_QA);
            }elif self.match.group(1) == "@TODO" {
                
                here.inquiry_by_user = self.match.group(2);
                visit [-->](`?user_TODO);
            }
        }
        else
        {
            print("Kindly add a routing method by using @ in the start of your question\nTo visit TODO : @TODO\nTo visit RAG : @RAG\nTo visit QA : @QA");
            visit [<--];
        }
    }
    else{
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
    #if (input("Start new chat (y/n)?") == "y")
    #{
    # Telescope into the nodes connected to the user node without walking.
    data_node = [-->](`?data)[0]; # Getting the data node filtered. can use [0] as having only one such node.
    todo_node = [-->](`?todo)[0]; # Getting the todo node filtered. can use [0] as having only one such node.
    new_session_id = str(str(uuid.uuid4()));

    # Creating a new session node with the user data and todo list and connect it to the user.
    n = here ++> session(   session_id = new_session_id,
                        user_data = data_node.user_data,
                        todo_list = todo_node.todo_list
                    );
    visit n;
    #}
    #else{
    #    print("Closing");
    #}
}
:walker:chat:can:chat_session{

        query() spawn here;
        visit[<--];
        
}

