console.log("add server")

// install the libraries required
const express = require('express')
const mysql = require('mysql');

// print that we are starting the server 
console.log("starting server");

// mysql home server
// password is your normal F133 password
// fcl03570@mzico.com (10/02/22)

const CONNECTION_DETAILS = {
  host     : 'chai-db.c2otfg86lzta.ap-southeast-1.rds.amazonaws.com',
  database : 'my_db',
  user     : 'admin',
  port     : '3306',
  password : 'nofpAz-zytke6-vycbyz',
}

var connection;

// test connection
// connect to MySQL server
try {
    _sqlConnect(() => {
        // UNCOMMENT ON FIRST RUN
        connection.query('CREATE TABLE IF NOT EXISTS Users ( userId int, username varchar(256), password varchar(256) ) ', function (error, results, fields) {
            if (error) throw error;
        });
        connection.query('CREATE TABLE IF NOT EXISTS PostData ( views int, postDataId int, ratingScore int, ratingNumber int, data text ) ', function (error, results, fields) {
            if (error) throw error;
        });
        connection.query('CREATE TABLE IF NOT EXISTS Posts ( postId int, postDataId int, userId int, comments text, date datetime ) ', function (error, results, fields) {
            if (error) throw error;
        });

        /*
        connection.query(
            `DELETE FROM Posts`, function (err, results, fields) {
        connection.query(
            `DELETE FROM PostData`, function (err, results, fields) {
            */

        // retrieve all server data
        // query server for post data
        connection.query(
            `SELECT * FROM PostData`, function (error, results, fields) {
            if (error) throw error;     // error trapping
            console.log(results);       // debug out the results
            // query server for the posts
            connection.query(
                `SELECT * FROM Posts`, function (error, results, fields) {
                if (error) throw error;     // error trapping
                console.log(results);       // debug out the results
                // query server for all the users
                connection.query(
                    `SELECT * FROM Users`, function (error, results, fields) {
                    if (error) throw error;
                    console.log(results);       // debug out the results
                        _sqlDisconnect();
                }); // end connection 3
            });     // end connection 2
        });         // end connection 1

        /*
        });
        });
        */

        console.log("TEST: PASSED   connected to server ");
    });
} catch {
    console.log("TEST: FAILED   failed to connect to database");
}

// start the application server via Express library
const app = express()   // setup Express
const port = 3000       // specify the port required

// override CORS policy of Chrome
const cors = require('cors');
app.use(cors());
app.use(express.json({limit: '10gb'}));
//app.use(express.urlencoded({limit: '10gb'}));

// connect to the MySQL server
var connected = false;

function _sqlConnect(callback) {
    if (connected)  // if already connected
        return;
    // handshake
    connection = mysql.createConnection(CONNECTION_DETAILS);
    // then perform connection
    connection.connect((err) => {
        if (err) {
            console.log(err.message);
            throw err;
        }
        connected = true;
        console.log("SQL:   Connected");
        callback();
    });
}

// disconnect from the MySQL server
function _sqlDisconnect() {
    if (!connected)  // if already disconnected
        return;

    // terminate connection to server
    connection.end();
    connected = false;
    console.log("SQL:   Disconnected");
}

// this is called everytime a request is GET'ted at localhost
app.get('/', function (request, response) { // call a function where request and response are arguments
});

// this is called everytime a request is GET'ted at localhost
app.post('/', function (request, response) { // call a function where request and response are arguments
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
});