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

    //     @http:ResourceConfig {
    //         methods: ["POST"],
    //         path: "/books",
    //         produces: ["application/json"]
    //     }
    //     resource function createBook(http:Caller caller, http:Request request) {
    //     }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/books",
        produces: ["application/json"]
    }
    resource function readBooks(http:Caller caller, http:Request request) {
        stream <record {}, error> resultStream = db->query("SELECT id, title FROM books", Book);
        stream<Book, error> bookStream = <stream<Book, error>>resultStream;
        var reducer = function (json[] items, Book row) returns json[] {
            items.push(row["title"]);
            return items;
        };
        json[]|error items = bookStream.reduce(reducer, []);
        http:Response res = new;
        if (items is error) {
            // TODO
        }
        else {
            json booksPayload = {
                "items": items
            };
            res.setJsonPayload(<@untainted>booksPayload);
        }
        error? result = caller->respond(res);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/books/{bookId}",
        produces: ["application/json"]
    }
    resource function readBook(http:Caller caller, http:Request request, string bookId) {
        string query = io:sprintf("SELECT id, title FROM books WHERE id = %s", bookId);
        stream <record {}, error> resultStream = db->query(query);
        var row = resultStream.next();

        http:Response res = new;
        if (row is error) {
            // TODO
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
                // TODO
            } else {
                res.setPayload(<@untainted>bookPayload);
            }
        }
        error? result = caller->respond(res);
    }

// @http:ResourceConfig {
//     methods: ["PATCH"],
//     path: "/books/{bookId}",
//     produces: ["application/json"]
// }
// resource function updateBook(http:Caller caller, http:Request request, string bookId) {

// }

// @http:ResourceConfig {
//     methods: ["DELETE"],
//     path: "/books/{bookId}",
//     produces: ["application/json"]
// }
// resource function deleteBook(http:Caller caller, http:Request request, string bookId) {

// }
}