const Db = require('./database');
const Token = require('./token');
const CourseSections = require('../courseSections');

var videos = new Db.DatabaseTable("Videos",
    "videoId",
    [
        {
        name: "courseSectionId",
        type: "int"
        },
        {
        name: "videoDataId",
        type: "varchar(16)"
        },
        {
        name: "elementOrder",
        type: "int"
        },
        {
        name: "duration",
        type: "int"
        },
        {
        name: "videoName",
        type: "varchar(50)"
        },
        {
        name: "videoDescription",
        type: "varchar(50)"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
]);
videos.init();

async function createVideo (token, courseSectionId, videoOptions) {
    // check auth
    CourseSection.assertUserCanEditCourseSection(token, courseSectionId);

    // determine next element order
    let elementOrder = 0;

    // create video
    var videoId = Token.generateToken();

    let videoId = videos.insertInto({
        courseSectionId: courseSectionId,
        videoDataId: videoId,
        elementOrder: elementOrder,
        duration: "?",
        videoName: videoOptions.videoName,
        videoDescription: videoOptions.videoDescription,
        dateCreated: Db.getDatetime(),
    });

    return videoId;
}

async function removeVideo (token, videoId) {
    // check auth
    CourseSection.assertUserCanEditCourseSection(token, courseSectionId);

    // remove video
    videos.deleteFrom({"videoDataId": videoId});
}

async function addForm (token, courseSectionId, formOptions) {
}

async function removeForm (token, formId) {
}

async function swapElementOrder (token, element1, element2) {
}

module.exports.addVideo = createVideo;
module.exports.removeVideo = removeVideo;