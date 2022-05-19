const Db = require('./database');
const Token = require('./token');

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

async function createVideo (token, videoOptions) {
    // TODO: auth check token that they can add a course to courseSection

    var videoId = Token.generateToken();

    videos.insertInto({
        courseSectionId: videoOptions.courseSectionId,
        videoDataId: videoId,
        elementOrder: videoOptions.elementOrder,
        duration: "?",
        videoName: videoOptions.videoName,
        videoDescription: videoOptions.videoDescription,
        dateCreated: Db.getDatetime(),
    });

    return {videoId: videoId};
}

async function removeVideo (token, videoId) {
    // TODO: auth check token
    videos.deleteFrom({"videoDataId": videoId});
}

async function addForm (token, courseSectionId, formOptions) {
}

async function removeForm (token, formId) {
}

async function changeElementOrder (token, element1, element2) {
}

module.exports.addVideo = createVideo;
module.exports.removeVideo = removeVideo;