import: py from langchain_community.document_loaders, PyPDFDirectoryLoader;
import: py from langchain_text_splitters, RecursiveCharacterTextSplitter;
import: py from langchain.schema.document, Document;
import: py from langchain_community.embeddings.ollama, OllamaEmbeddings;
import: py from langchain_community.vectorstores.chroma, Chroma;
import: py os;
import: py argparse;
import: py shutil;

import: py from jaclang.core.llms, OpenAI;

glob llm = OpenAI(model_name='gpt-4');

glob file_path:str="books";
glob chroma_path:str = "chroma";
glob query:str ="What are the reasons for a back pain?";

can load_documents(){
    document_loader = PyPDFDirectoryLoader(file_path);
    return document_loader.load();
}

can split_documents(documents: list[Document]){
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=800,
    chunk_overlap=80,
    length_function=len,
    is_separator_regex=False);
    return text_splitter.split_documents(documents);
}

can get_embedding_function(){
    embeddings = OllamaEmbeddings(model='nomic-embed-text');
    return embeddings;
}

can add_chunk_id(chunks:str){
    last_page_id = None;
    current_chunk_index = 0;
    
    for chunk in chunks{
        source = chunk.metadata.get('source');
        page = chunk.metadata.get('page');
        current_page_id = f'{source}:{page}';

        if current_page_id == last_page_id{
            current_chunk_index +=1;
        }

        else{
            current_chunk_index = 0;
        }

        chunk_id = f'{current_page_id}:{current_chunk_index}';
        last_page_id = current_page_id;

        chunk.metadata['id'] = chunk_id;
    }

    return chunks;
}

can add_to_chroma(chunks: list[Document]){
    db = Chroma(persist_directory=chroma_path, embedding_function=get_embedding_function());
    chunks_with_ids = add_chunk_id(chunks);

    existing_items = db.get(include=[]);
    existing_ids = set(existing_items['ids']);

    new_chunks = [];
    for chunk in chunks_with_ids{
        if chunk.metadata['id'] not in existing_ids{
            new_chunks.append(chunk);
        }
        
    }

    if len(new_chunks){
        print('adding new documents');
        new_chunk_ids = [chunk.metadata['id'] for chunk in new_chunks];
        db.add_documents(new_chunks, ids=new_chunk_ids);
    }

    else{
        print('no new documents to add');
    }
    
}


can get_from_chroma(query:str){
    db = Chroma(persist_directory=chroma_path, embedding_function=get_embedding_function());
    results = db.similarity_search_with_score(query,k=5);
    print(type(results));
    return results;
}

can 'Generate a conversational response to the question like a doctor'
    get_answer(
    question: 'Question': str,
    context: 'The context': str 
    ) -> 'The response': str 
    by llm();


with entry{
    documents = load_documents();
    chunks = split_documents(documents);
    add_to_chroma(chunks);
    print(get_answer(question=query, context=get_from_chroma(query)));
}


