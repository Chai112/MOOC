const fs = require('fs');

const VideoUpload = require("./videoUpload");

function post(action, request, response) {
    switch (action) {
        case "upload-video":
            console.log("videoUpload:   UPLOADING...");
            var body = '';
            filePath = __dirname + '/public/nocturne.mp4';
            request.on('data', function(data) {
                body += data;
                //console.log(data);
            });

            request.on('end', function (){
                fs.writeFile(filePath, body, function() {
                    response.send("uploaded video successfully");
                });
            });
            //const data = request.body.data; 
            //let videoDataId = VideoUpload.uploadVideo(data);
    }
}
module.exports.post = post;