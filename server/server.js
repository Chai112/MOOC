// install the libraries required
const express = require('express');

// start the application server via Express library
const app = express()   // setup Express
const port = 3000       // specify the port required

// override CORS policy of Chrome
const cors = require('cors');
app.use(cors());
app.use(express.json({limit: '10gb'}));

const db = require('./database');

// print that we are starting the server 
console.log("starting server");

// mysql home server
// password is your normal F133 password
// fcl03570@mzico.com (10/02/22)


test();
async function test() {
    // test connection
    // connect to MySQL server
    //try {
        //await db.query("hey");
        var users = new db.DatabaseTable("Users",
            [
                {
                "name": "username",
                "type": "varchar(50)"
                },
                {
                "name": "password",
                "type": "varchar(32)"
                }
        ]);
        users.init();
        await users.dropTable();
        users = new db.DatabaseTable("Users",
            [
                {
                "name": "username",
                "type": "varchar(50)"
                },
                {
                "name": "password",
                "type": "varchar(32)"
                }
        ]);
        users.init();
        await users.insertIntoTable(
        {
            username: "cat",
            password: "bat"
        });
        await users.insertIntoTable(
        {
            username: "cat",
            password: "mat"
        });
        let data = await users.selectTable();
        console.log(data);
        users.updateTable(
            // where...
            {username: "cat"},
            // set entry to...
            {
                username: "bat",
                password: "nat",
            }
        );
        data = await users.selectTable();
        console.log(data);
        console.log("TEST: PASSED   successfully connected to database");
        /*
    } catch {
        console.log("TEST: FAILED   failed to connect to database");
    }
    */
}

//app.use(express.urlencoded({limit: '10gb'}));


// this is called everytime a request is GET'ted at localhost
app.get('/', function (request, response) { // call a function where request and response are arguments
});

// this is called everytime a request is GET'ted at localhost
app.post('/', function (request, response) { // call a function where request and response are arguments
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
});