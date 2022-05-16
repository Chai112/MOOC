// install the libraries required
const express = require('express');

// start the application server via Express library
const app = express()   // setup Express
const port = 3000       // specify the port required

// override CORS policy of Chrome
const cors = require('cors');
app.use(cors());
app.use(express.json({limit: '10gb'}));

const Db = require('./database');

// this is called everytime a request is GET'ted at localhost
app.get('/', function (request, response) { // call a function where request and response are arguments
});

// this is called everytime a request is GET'ted at localhost
app.post('/', function (request, response) { // call a function where request and response are arguments
});

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
});