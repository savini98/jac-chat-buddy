import:py from jaclang.core.llms, Anthropic, Ollama, Groq;
import:py from langchain_chroma, Chroma;
import:py from langchain_openai,OpenAIEmbeddings;
import:py from langchain.docstore.document, Document;
import:py from langchain_community.document_loaders, PyMuPDFLoader;
import:py from langchain_openai, OpenAIEmbeddings;
import:py from langchain_text_splitters,CharacterTextSplitter;
import:py from langchain_chroma, Chroma;
import:py os;
glob llm = Groq();

glob openai_api_key = os.getenv("OPENAI_API_KEY", "");

node chroma_con{

}

can insert_to_chroma(file_path:str,chroma_db_path:str) -> None{
    if file_path.endswith(".pdf"){
        raw_documents =  PyMuPDFLoader(file_path).load();
        text_splitter = CharacterTextSplitter(chunk_size=1000, chunk_overlap=0);
        documents = text_splitter.split_documents(raw_documents);
        db = Chroma.from_documents(documents, OpenAIEmbeddings(openai_api_key=openai_api_key),persist_directory=chroma_db_path);
    }

}

can retrieve_from_chroma(query:str,chroma_db_path:str,number_of_similar_docs:int) -> List[Document]{
    db = Chroma(persist_directory=chroma_db_path,embedding_function=OpenAIEmbeddings(openai_api_key=openai_api_key));
    docs = db.similarity_search(query, k=number_of_similar_docs); 
    return [doc.page_content for doc in docs];
}


walker search_docs{
    has question:str="";
    has context:str="";
    has chroma_db_path:str = "";
    has number_of_similar_docs:int = 5;

    can search with `root entry{
        visit [-->];
    }
    
    can call_llm with chroma_con entry{
        self.context = retrieve_from_chroma(self.question,self.chroma_db_path,self.number_of_similar_docs);
        
    }

}

walker injest_docs{
    has file_path:str ="";
    has chroma_db_path:str = "";

    can injest with `root entry{
         n = here ++> chroma_con();
         visit n;
    }

    can call_llm with chroma_con entry{
        insert_to_chroma(self.file_path,self.chroma_db_path);
    }

}

walker guru{
    has question:str="";
    has answer:str="";
    has chroma_db_path:str = "";
    has number_of_similar_docs:int = 5;

    
    can 'Generate a conversational response to the question like a guru'
    get_answer(
    question: 'Question': str,
    context: 'The context': str 
    ) -> 'The response': str 
    by llm();


   can run with `root entry{
        response = root spawn (result := search_docs(question=self.question,chroma_db_path=self.chroma_db_path,number_of_similar_docs=self.number_of_similar_docs));
        self.answer = self.get_answer(question=self.question,context=response.context);
    }

}

with entry:__main__{
    root spawn (result := injest_docs(file_path="four-hour-workweek.pdf",chroma_db_path="./chroma_db"));
    # guru= root spawn (result := guru(question="Who is the author of this pdf?",chroma_db_path="./chroma_db",number_of_similar_docs=5));
    guru= root spawn (result := guru(question="I am always so busy with my work stuff during the week. How can I improve that and get some more free time?",chroma_db_path="./chroma_db",number_of_similar_docs=5));
    # guru= root spawn (result := guru(question="I am struggling at work recently, I need to improve my productivity",chroma_db_path="./chroma_db",number_of_similar_docs=5));
    # guru= root spawn (result := guru(question="I have been hearing about this 4 hour work week concept, tell me more please.",chroma_db_path="./chroma_db",number_of_similar_docs=5));
    # guru= root spawn (result := guru(question="Hey do you have any productivity tips for me?",chroma_db_path="./chroma_db",number_of_similar_docs=5));
    print(guru.answer); 
}