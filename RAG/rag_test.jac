import: py from langchain_community.document_loaders, PyPDFDirectoryLoader;
import: py from langchain_text_splitters, RecursiveCharacterTextSplitter;
import: py from langchain.schema.document, Document;

glob file_path:str="books";

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

with entry{
    documents = load_documents();
    print(documents[0]);

    chunks = split_documents(documents);
    print(chunks[0]);
}


