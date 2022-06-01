const Auth = require('./auth');
const Org = require('./organizations');
const Courses = require('./courses');
const CourseSections = require('./courseSections');
const CourseElements = require('./courseElements');
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
            case "getUserFromToken":
                this.getUserFromToken();
                break;
            case "login":
                this.login();
                break;
            case "register":
                this.register();
                break;
            case "createVideo":
                this.createVideo();
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
                this.response.status(400);
                this.response.json({"message": "invalid action"});
                return;
        }
    }
    _getQuery(query) {
        let answer = this.request.query[query];
        if (answer !== undefined) {
            return answer;
        } else {
            this.response.status(400);
            this.response.json({"message": `query '${query}' expected in url but not found`})
            throw "error";
        }
    }
    async getUserFromToken() {
        let token = this._getQuery("token");
        let userData = {};
        let data = await Auth.getUserFromToken(token);
        if (data.length < 0) { // no token found
            this.response.status(403);
            this.response.json({message: "no token found"});
            return;
        }
        userData = data[0];
        this.response.status(200);
        this.response.json({
            "username": userData.username,
            "email": userData.email,
            "firstName": userData.firstName,
            "lastName": userData.lastName,
        });
    }
    async login() {
        let username = this._getQuery("username");
        let password = this._getQuery("password");
        let token = "";
        try {
            token = await Auth.loginUser(username, password);
        } catch (err) {
            switch (err) {
                case "no user exists":
                    this.response.status(403);
                    this.response.json({message: err});
                    return;
                case "passwords do not match":
                    this.response.status(403);
                    this.response.json({message: err});
                    return;
                default:
                    this.response.status(500);
                    this.response.json({message: "unreachable"});
                    return;
            }
        }
        this.response.status(200);
        this.response.json({"token": token});
    }
    async register() {
        let username = this._getQuery("username");
        let password = this._getQuery("password");
        let email = this._getQuery("email");
        let firstName = this._getQuery("firstName");
        let lastName = this._getQuery("lastName");
        let token = "";
        try {
            token = await Auth.registerUser(username, password, email,firstName, lastName);
        } catch (err) {
            switch (err) {
                case "user already exists":
                    this.response.status(403);
                    this.response.json({message: err});
                    return;
            }
        }
        this.response.status(200);
        this.response.json({"token": token});
    }
    /*
    createVideo() {
        let token = this._getQuery("token");
        let videoOptions = {};

        videoOptions.courseSectionId = this._getQuery("courseSectionId");
        videoOptions.videoName = this._getQuery("videoName");
        videoOptions.elementOrder = this._getQuery("elementOrder");
        videoOptions.videoName = this._getQuery("videoDescription");
        this.response.json(CourseElements.createVideo(token, videoOptions));
    }
    removeVideo() {
        let token = this._getQuery("token");
        let videoId = this._getQuery("videoid");
        this.response.json(CourseElements.removeVideo(videoId));
    }
    getVideoUploadProgress() {
        let videoId = this._getQuery("videoId");
        this.response.json(VideoData.getVideoUploadProgress(videoId));
    }
    */
}


module.exports.Router = Router;
