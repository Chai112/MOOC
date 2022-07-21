const fs = require('fs');

const multer = require('multer');
const path = require('path');

const videoUploadProgress = new Map();

function downloadVideo(router) {
    // TODO: auth check if ID & token can work

    let videoId = router._getQuery("videoId");

    console.log("downloading");
    const path = `${__dirname}/videos/${videoId}.mp4`;
    const stat = fs.statSync(path)
    const fileSize = stat.size
    const range = router.request.headers.range
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
        router.response.writeHead(206, head);
        file.pipe(router.response);
    } else {
        const head = {
        'Content-Length': fileSize,
        'Content-Type': 'video/mp4',
        }
        router.response.writeHead(200, head)
        fs.createReadStream(path).pipe(router.response)
    }
}

function uploadVideo(router) {
    // TODO: check if ID is valid

    let videoId = router._getQuery("videoId");

    const videoStorage = multer.diskStorage({
        destination: 'videos', // Destination to store video 
        filename: (req, file, cb) => {
            cb(null, videoId
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

    console.log(router.request.headers);
    console.log("uploading");
    let progress = 0;
    let fileSize = router.request.headers['content-length'] ? parseInt(router.request.headers['content-length']) : 0;
    router.request.on('data', (chunk) => {
        progress += chunk.length;
        progressString = `${Math.floor((progress * 100) / fileSize)}%`;
        //videoUploadProgress.set(videoId, progressString);
        if (progress === fileSize) {
            console.log('Finished', progress, fileSize)
        }
    });
    videoUploadSingle(router.request, router.response, (err) => {
        if (err !== undefined)
            console.log(err);
        router.response.send(router.request.file)
        console.log("finish");
        //videoUploadProgress.delete(videoId);
    });
}

function getVideoUploadProgress (videoId) {
    if (!videoUploadProgress.has(videoId))
        return {progress: "none exists"};
    return {progress: videoUploadProgress.get(videoId)};
}

module.exports.downloadVideo = downloadVideo;
module.exports.uploadVideo = uploadVideo;
module.exports.getVideoUploadProgress = getVideoUploadProgress;
