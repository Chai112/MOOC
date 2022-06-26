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
        console.log(`parsing action: ${action}`);
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
            case "getOrganizations":
                this.getOrganizations();
                break;
            case "getOrganization":
                this.getOrganization();
                break;
            case "createOrganization":
                this.createOrganization();
                break;
            case "getCourses":
                this.getCourses();
                break;
            case "getCourse":
                this.getCourse();
                break;
            case "createCourse":
                this.createCourse();
                break;
            case "changeCourseOptions":
                this.changeCourseOptions();
                break;
            case "removeCourse":
                this.removeCourse();
                break;
            case "getCourseHierarchy":
                this.getCourseHierarchy();
                break;
            case "createCourseSection":
                this.createCourseSection();
                break;
            case "editCourseSection":
                this.editCourseSection();
                break;
            case "removeCourseSection":
                this.removeCourseSection();
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
                default:
                    this.response.status(500);
                    this.response.json({message: "unreachable"});
                    return;
            }
        }
        this.response.status(200);
        this.response.json({"token": token});
    }
    async getOrganizations() {
        let token = this._getQuery("token");
        let data;
        try {
            data = await Org.getOrganizationsForUser(token);
        } catch (err) {
            this.response.status(500);
            this.response.json({message: "unreachable"});
            return;
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getOrganization() {
        let token = this._getQuery("token");
        let organizationId = this._getQuery("organizationId");
        let orgData;
        try {
            // TODO: there should be an authentication check
            orgData = await Org.getOrganization(organizationId);
        } catch (err) {
            this.response.status(500);
            this.response.json({message: "unreachable"});
            return;
        }
        this.response.status(200);
        this.response.json({
            "data": orgData[0],
        });
    }
    async createOrganization() {
        let token = this._getQuery("token");
        let organizationName = this._getQuery("organizationName");
        let orgData;
        try {
            orgData = await Org.createOrganization(token, {
                organizationName: organizationName,
            });
        } catch (err) {
            this.response.status(500);
            this.response.json({message: "unreachable"});
            return;
        }
        this.response.status(200);
        this.response.json({
            "organizationId": orgData.organizationId,
            "organizationPrivilegeId": orgData.organizationPrivilegesId,
        });
    }
    async getCourses() {
        let token = this._getQuery("token");
        let organizationId = this._getQuery("organizationId");
        let data;
        try {
            data = await Courses.getCoursesForOrganization(token, organizationId);
        } catch (err) {
            switch (err) {
                case "assigner not part of organization":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                default:
                    this.response.status(500);
                    this.response.json({message: "unreachable"});
                    return;
            }
        }
        this.response.status(200);
        this.response.json({"data": data});
    }
    async getCourse() {
        let token = this._getQuery("token");
        let courseId = this._getQuery("courseId");
        let courseData;
        try {
            // TODO: there should be an authentication check
            courseData = await Courses.getCourse(courseId);
        } catch (err) {
            this.response.status(500);
            this.response.json({message: "unreachable"});
            return;
        }
        this.response.status(200);
        this.response.json({
            "data": courseData[0],
        });
    }
    async createCourse() {
        let token = this._getQuery("token");
        let organizationId = this._getQuery("organizationId");
        let courseName = this._getQuery("courseName");
        let courseData;
        try {
            courseData = await Courses.addCourse(token, organizationId, {
                courseName: courseName,
                courseDescription: "",
            });
        } catch (err) {
            switch (err) {
                case "assigner not part of organization":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                case "assigner has insufficient permission":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                default:
                    this.response.status(500);
                    this.response.json({message: "unreachable"});
                    return;
            }
        }
        this.response.status(200);
        this.response.json({
            "courseId": courseData.courseId,
            "coursePrivilegeId": courseData.coursePrivilegeId,
        });
    }
    async changeCourseOptions() {
        let token = this._getQuery("token");
        let courseId = this._getQuery("courseId");
        let courseName = this._getQuery("courseName");
        let courseDescription = this._getQuery("courseDescription");
        try {
            await Courses.changeCourseOptions(token, courseId,
            {
                courseName: courseName,
                courseDescription: courseDescription,
            });
        } catch (err) {
            switch (err) {
                case "assigner not part of organization":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                case "assigner has insufficient permission":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                default:
                    this.response.status(500);
                    this.response.json({message: "unreachable"});
                    return;
            }
        }
        this.response.status(200);
        this.response.json({});
    }

    async removeCourse() {
        let token = this._getQuery("token");
        let courseId = this._getQuery("courseId");

        try {
            await Courses.removeCourse(token, courseId);
        } catch (err) {
            switch (err) {
                case "assigner not part of organization":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                case "assigner has insufficient permission":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                default:
                    this.response.status(500);
                    this.response.json({message: "unreachable"});
                    return;
            }
        }
        this.response.status(200);
        this.response.json({});
    }
    async getCourseHierarchy() {
        let token = this._getQuery("token");
        let courseId = this._getQuery("courseId");
        let data;
        try {
            data = await CourseSections.getCourseHierarchy(token, courseId);
        } catch (err) {
            switch (err) {
                case "assigner not part of organization":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                case "assigner not part of course":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                default:
                    this.response.status(500);
                    this.response.json({message: "unreachable"});
                    return;
            }
        }
        this.response.status(200);
        this.response.json({
            "data": data,
        });
    }
    async createCourseSection() {
        let token = this._getQuery("token");
        let courseId = this._getQuery("courseId");
        let courseSectionName = this._getQuery("courseSectionName");
        let courseSectionId;

        try {
            courseSectionId = await CourseSections.addCourseSection(token, courseId, 
                { courseSectionName: courseSectionName }
            );
        } catch (err) {
            switch (err) {
                case "assigner not part of organization":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                case "assigner not part of course":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                case "assigner has insufficient permission":
                    this.response.status(400);
                    this.response.json({message: err});
                    return;
                default:
                    this.response.status(500);
                    this.response.json({message: "unreachable"});
                    return;
            }
        }
        this.response.status(200);
        this.response.json({
            "courseSectionId": courseSectionId,
        });
    }
    async editCourseSection() {

    }
    async removeCourseSection() {

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
