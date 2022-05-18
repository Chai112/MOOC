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

// this is called everytime a request is GET'ted at localhost
app.get('/', function (request, response) { // call a function where request and response are arguments
  const action = request.query.action;
  Route.parse(action, request, response);
});

// this is called everytime a request is POST'ed at localhost
app.post('/', function (request, response) { // call a function where request and response are arguments
  const action = request.query.action;
  console.log(action);
  Route.parse(action, request, response);
});

app.listen(port, () => {
  console.log(`http://ec2-54-255-233-46.ap-southeast-1.compute.amazonaws.com:${port}`)
});