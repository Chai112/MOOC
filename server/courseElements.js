const Db = require('./database');
const Token = require('./token');
const CourseSections = require('./courseSections');

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

module.exports.DO_NOT_RUN_FULL_RESET = DO_NOT_RUN_FULL_RESET;
async function DO_NOT_RUN_FULL_RESET() {
    await videos.drop();
    await videos.init();
}

module.exports.createVideo = createVideo;
async function createVideo (token, courseSectionId, videoOptions) {
    // check auth
    CourseSections.assertUserCanEditCourseSection(token, courseSectionId);

    // determine next element order
    let elementOrder = 0;

    // create video
    var videoDataId = Token.generateToken();

    let videoId = videos.insertInto({
        courseSectionId: courseSectionId,
        videoDataId: videoDataId,
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

module.exports.getAllElementsFromCourseSection = getAllElementsFromCourseSection;
async function getAllElementsFromCourseSection(courseSectionId) {
    let videoOutput = await videos.select({ courseSectionId: courseSectionId });
    let formOutput = [] //await forms.select({ courseSectionId: courseSectionId });
    let output = [];
    for (let i = 0; i < videoOutput.length; i++) {
        output.push(videoOutput[i]);
    }
    for (let i = 0; i < formOutput.length; i++) {
        output.push(formOutput[i]);
    }
    return output;
}

module.exports.addVideo = createVideo;
module.exports.removeVideo = removeVideo;