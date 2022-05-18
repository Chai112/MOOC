const fs = require('fs');

const multer = require('multer');
const path = require('path');

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
    }
})
const videoUploadSingle = videoUpload.single('video');
const videoUploadProgress = new Map();

function downloadVideo(request, response) {
    // TODO: check if ID is valid

        console.log("downloading");
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
}

function uploadVideo(request, response) {
    // TODO: check if ID is valid

    let videoId = request.query.videoId;
    console.log("uploading");
    let progress = 0;
    let fileSize = request.headers['content-length'] ? parseInt(request.headers['content-length']) : 0;
    request.on('data', (chunk) => {
        progress += chunk.length;
        progressString = `${Math.floor((progress * 100) / fileSize)}%`;
        videoUploadProgress.set(videoId, progressString);
        if (progress === fileSize) {
            console.log('Finished', progress, fileSize)
        }
    });
    videoUploadSingle(request, response, (err) => {
        if (err !== undefined)
        console.log(err);
        response.send(request.file)
        console.log("finish");
        videoUploadProgress.delete(videoId);
    });
}
function getVideoUploadProgress (videoId) {
    if (!VideoData.videoUploadProgress.has(videoId))
        return {progress: "100%"};
    return {progress: VideoData.videoUploadProgress.get(videoId)};
}

module.exports.downloadVideo = downloadVideo;
module.exports.uploadVideo = uploadVideo;
module.exports.getVideoUploadProgress = getVideoUploadProgress;
