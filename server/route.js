const Video = require("./videos");
const VideoData = require("./videoData");


class Router{
    request;
    response;

    constructor (request, response){
        this.request = request;
        this.response = response;
    }

    parse (action) {
        switch (action) {
            case "addVideo":
                this.addVideo();
                break;
            case "removeVideo":
                this.removeVideo();
                break;
            case "downloadVideo":
                VideoData.downloadVideo(this);
                break;
            case "uploadVideo":
                VideoData.uploadVideo(this);
                break;
            case "getVideoUploadProgress":
                this.getVideoUploadProgress();
                break;

            default:
                response.json({"message": "invalid action"});
                return;
        }
    }
    _getQuery(query) {
        let answer = this.request.query[query];
        if (answer !== undefined) {
            return answer;
        } else {
            this.response.json({"message": `query '${query}' expected in url but not found`})
            throw "error";
        }
    }
    addVideo() {
        let token = this._getQuery("token");
        let videoOptions = {};

        videoOptions.courseSectionId = this._getQuery("courseSectionId");
        videoOptions.videoName = this._getQuery("videoName");
        videoOptions.elementOrder = this._getQuery("elementOrder");
        videoOptions.videoName = this._getQuery("videoDescription");
        this.response.json(Video.addVideo(token, videoOptions));
    }
    removeVideo() {
        let token = this._getQuery("token");
        let videoId = this._getQuery("videoid");
        this.response.json(Video.removeVideo(videoId));
    }
    getVideoUploadProgress() {
        let videoId = this._getQuery("videoId");
        this.response.json(VideoData.getVideoUploadProgress(videoId));
    }
}


module.exports.Router = Router;
