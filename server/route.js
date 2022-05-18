const VideoData = require("./videoData");

// TEMPORARY
// TEMPORARY
// TEMPORARY
const Token = require('./token');

function parse(action, request, response) {
    switch (action) {
        case "addVideo":
            let videoName = request.query.videoName;
            response.json(addVideo(videoName));
            break;

        case "downloadVideo":
            VideoData.downloadVideo(request, response);
            break;

        case "uploadVideo":
            VideoData.uploadVideo(request, response);
            break;

        case "getVideoUploadProgress":
            let videoId = request.query.videoId;
            response.json(VideoData.getVideoUploadProgress(videoId));
            break;

        default:
            response.json({"message": "invalid action"});
            return;
    }
}
module.exports.parse = parse;

function addVideo (videoName) {
    var videoId = Token.generateToken();
    return {videoId: videoId};
}