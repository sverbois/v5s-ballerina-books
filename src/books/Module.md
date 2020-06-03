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
