// import ballerina/config;
import ballerina/http;
import ballerina/io;
import ballerina/java.jdbc;

jdbc:Client db = check new (
        url = "jdbc:postgresql://localhost:5432/books",
        user = "ballerina",
        password = "blpsvp"
    );

listener http:Listener booksListener = new (9090);

@http:ServiceConfig {
    basePath: "/v1"
}
service booksService on booksListener {

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/books",
        consumes: ["application/json"],
        body: "book"
    }
    resource function createBook(http:Caller caller, http:Request request, json book) {
        string query = io:sprintf("INSERT INTO books (title, isbn, pages, date) VALUES ('%s', '%s', %d, '%s')",
            book.title, book.isbn, book.pages, book.date);
        var result = db->execute(query);
        http:Response res = new;
        if(result is error) {
            res.statusCode = 500;
        } else {
            string location =  io:sprintf("http://TODO/%s", result["lastInsertId"]); 
            res.statusCode = 201;
            res.setHeader("location", location);
        }
        error? e = caller->respond(res);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/books",
        produces: ["application/json"]
    }
    resource function readBooks(http:Caller caller, http:Request request) {
        stream <record {}, error> resultStream = db->query("SELECT * FROM books");
        var reducer = function (json[] items, record {} row) returns json[] {
            var item = json.constructFrom(row);
            if (!(item is error)) {
                items.push(item);  
            }
            return items;
        };
        json[]|error items = resultStream.reduce(reducer, []);
        http:Response res = new;
        if(items is error) {
            res.statusCode = 500;
        } else {
            json booksPayload = {
                "items": items
            };
            res.setJsonPayload(<@untainted>booksPayload);
        }
        error? e = caller->respond(res);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/books/{bookId}",
        produces: ["application/json"]
    }
    resource function readBook(http:Caller caller, http:Request request, string bookId) {
        string query = io:sprintf("SELECT * FROM books WHERE id = %s", bookId);
        stream <record {}, error> resultStream = db->query(query);
        var row = resultStream.next();

        http:Response res = new;
        if (row is error) {
            res.statusCode = 500;
        } else if (row == ()) {
            res.statusCode = 404;
            string message = io:sprintf("Book %s does not exist", bookId);
            json errorPayload =  {
                "error": {
                    "code": 404,
                    "reason": "Not found",
                    "message": message
                }
            };
            res.setPayload(<@untainted>errorPayload);
        } else {
            json|error bookPayload = json.constructFrom(row);
            if (bookPayload is error) {
                res.statusCode = 500;
            } else {
                res.setPayload(<@untainted>bookPayload);
            }
        }
        error? e = caller->respond(res);
    }

// @http:ResourceConfig {
//     methods: ["PATCH"],
//     path: "/books/{bookId}",
//     produces: ["application/json"]
// }
// resource function updateBook(http:Caller caller, http:Request request, string bookId) {

// }

    @http:ResourceConfig {
        methods: ["DELETE"],
        path: "/books/{bookId}"
    }
    resource function deleteBook(http:Caller caller, http:Request request, string bookId) {
        string query = io:sprintf("DELETE FROM books WHERE id = %s", bookId);
        var result = db->execute(query);
        http:Response res = new;
            if(result is error) {
                res.statusCode = 500;
            } else {
                res.statusCode = 204;
            }
            error? e = caller->respond(res);
    }
}
