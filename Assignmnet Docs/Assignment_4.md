## Assignment 4 - Preface

### Implementing Retrieval Augmented Generation

To implement a RAG powered chatbot in jac-lang, different methodologies can be adopted. In this tutorial we are using a separate .jac file including all functionalities required for RAG as methods of an object.

**Main Object :** ```rag_engine```

 - This object handles information storing and retrieval. 

   > **Document Loader :** ```load_documents```

   - This function will load all source documents (PDF files)

   > **Document Splitter :** ```split_documents```

   - The PDF documents are broken down into smaller chunks.

   > **Embedding Function :** ```get_embedding_function```

   - Embeddings are generated for each chunk using an embedding model.
   - In this implementation we are using OllamaEmbeddings from langchain using the model nomic-embed-text.

   > **Chunk ID Modifier :** ```add_chunk_id```

   - This will generate a unique ID for each chunk which will allow better management of the existing data. 
   - When adding new documents, these IDs can be checked before adding the new document which indicated whether it is a new chunk or not.
   - Having the unique ID will also create a direct source link to where the information was extracted.

   > **Adding embeddings for Vector DB :** ```add_to_chroma```

   - Embeddings are saved in the vector database created using ChromaDB.
   - Documents are added to the V-DB only if they are not added to ChromaDB previously.

   > **Context Retrieval :** ```get_from_chroma```

   - Using the query passed into the query engine, 5 most relevent chunks are retrived from the vector DB which will be forwarded as the context for the LLM to generate a relevent response.

## Assignment 4 - Task

Add a RAG powered response generating feature for the chatbot and complete the full application implementation.

### Should Include
1. A RAG engine as described above. 
2. A full fledged chatbot in any domain (do not need to restrict to medical domain).
3. Can have multiple chats.