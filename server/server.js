// install the libraries required
const express = require('express');

// start the application server via Express library
const app = express()   // setup Express
const port = 3000       // specify the port required

// override CORS policy of Chrome
const cors = require('cors');
app.use(cors());
//app.use(express.json({limit: '10gb'}));

const Db = require('./database');
const Route = require('./route');
/*
STATUS CODES used in this project:
200 - OK
400 - bad request   client error (e.g., misspelt query/ not enough privilege)
403 - forbidden     user error (e.g., incorrect password) a message is provided via json
500 - server error  server error (really bad day)
*/

// this is called everytime a request is GET'ted at localhost
app.get('/', function (request, response) { // call a function where request and response are arguments
  const action = request.query.action;
  if (action === undefined) {
    response.status(400);
    response.json({message: "query 'action' expected in url but not found - specify the action"})
    return;
  }
  let router = new Route.Router(request, response);
  router.parse(action);
});

// this is called everytime a request is POST'ed at localhost
app.post('/', function (request, response) { // call a function where request and response are arguments
  const action = request.query.action;
  if (action === undefined) {
    response.status(400);
    response.json({message: "query 'action' expected in url but not found - specify the action"})
    return;
  }
  let router = new Route.Router(request, response);
  router.parse(action);
});

app.listen(port, () => {
  console.log(`http://ec2-54-255-233-46.ap-southeast-1.compute.amazonaws.com:${port}`)
});