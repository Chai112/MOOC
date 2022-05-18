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

// TEMPORARY
// TEMPORARY
// TEMPORARY
const fs = require('fs');
const multer = require('multer');
const path = require('path');

// this is called everytime a request is GET'ted at localhost
app.get('/', function (request, response) { // call a function where request and response are arguments
  //response.send("hello");
  const path = __dirname + "/videos/a.mp4";
  const stat = fs.statSync(path)
  const fileSize = stat.size
  const range = request.headers.range
  if (range) {
    const parts = range.replace(/bytes=/, "").split("-")
    const start = parseInt(parts[0], 10)
    const end = parts[1] 
      ? parseInt(parts[1], 10)
      : fileSize-1
    const chunksize = (end-start)+1
    const file = fs.createReadStream(path, {start, end})
    const head = {
      'Content-Range': `bytes ${start}-${end}/${fileSize}`,
      'Accept-Ranges': 'bytes',
      'Content-Length': chunksize,
      'Content-Type': 'video/mp4',
    }
    response.writeHead(206, head);
    file.pipe(response);
  } else {
    const head = {
      'Content-Length': fileSize,
      'Content-Type': 'video/mp4',
    }
    response.writeHead(200, head)
    fs.createReadStream(path).pipe(response)
  }
});

const videoStorage = multer.diskStorage({
  destination: 'videos', // Destination to store video 
  filename: (req, file, cb) => {
      cb(null, "a"
       + path.extname(file.originalname))
  }
});
const videoUpload = multer({
  storage: videoStorage,
  limits: {
  fileSize: 500000000 // 500000000 Bytes = 500 MB
  },
  fileFilter(req, file, cb) {
    // upload only mp4 and mkv format
    if (!file.originalname.match(/\.(mp4|MPEG-4|mkv)$/)) { 
       return cb(new Error('Please upload a video'))
    }
    cb(undefined, true)
    console.log("downloading");
    let progress = 0;
    let fileSize = req.headers['content-length'] ? parseInt(req.headers['content-length']) : 0;
    req.on('data', (chunk) => {
        progress += chunk.length;
        console.log((`${Math.floor((progress * 100) / fileSize)} `));
        if (progress === fileSize) {
            console.log('Finished', progress, fileSize)
        }
    });
 }
})
app.post('/uploadVideo', videoUpload.single('video'), (req, res) => {
  res.send(req.file)
  console.log("finish");
}, (error, req, res, next) => {
   res.status(400).send({ error: error.message })
})

// this is called everytime a request is POST'ed at localhost
app.post('/', function (request, response) { // call a function where request and response are arguments
  const action = request.query.action;
  console.log(action);
  Route.post(action, request, response);
});

app.listen(port, () => {
  console.log(`http://ec2-54-255-233-46.ap-southeast-1.compute.amazonaws.com:${port}`)
});