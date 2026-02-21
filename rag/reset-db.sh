rm rag-*.db
cat init.sql | sqlite3 rag-meta.db
