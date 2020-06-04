A simple CRUD Ballerina service

### Create books PostgreSQL database

```
    createdb books
    psql books

      CREATE USER ballerina WITH PASSWORD 'blpsvp';
      GRANT ALL PRIVILEGES ON DATABASE books to ballerina;

    psql -U ballerina books

      CREATE TABLE books (
        "id" SERIAL PRIMARY KEY,
        "title" VARCHAR NOT NULL,
        "isbn" VARCHAR,
        "pages" INT,
        "date" DATE            
      );

      INSERT INTO books ("title", "isbn", "pages", "date")
      VALUES
          ('La foire aux immortels','2203353275', 64, '2005-09-14'),
          ('Beginning Ballerina Programming','1484251386', 335, '2020-02-25');
```

### Add book with curl

```
curl "http://0.0.0.0:9090/v1/books" \
  -X POST \
  -d "{\"title\": \"Un petit livre\", \"isbn\": \"1234567890\", \"pages\": 27, \"date\":\"1971-06-27\"}" \
  -H "Content-Type: application/json" 
```