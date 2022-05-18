const Db = require('./database');

var videos = new Db.DatabaseTable("Videos",
    "videoId",
    [
        {
        "name": "courseSectionId",
        "type": "int"
        },
        {
        "name": "videoDataId",
        "type": "int"
        },
        {
        "name": "elementOrder",
        "type": "int"
        },
        {
        "name": "duration",
        "type": "int"
        },
        {
        "name": "videoName",
        "type": "varchar(50)"
        },
        {
        "name": "videoDescription",
        "type": "varchar(50)"
        },
        {
        "name": "dateCreated",
        "type": "datetime"
        },
]);
videos.init();

async function addVideo (token, courseSectionId, videoOptions) {
}

async function removeVideo (token, videoId) {
}

async function addForm (token, courseSectionId, formOptions) {
}

async function removeForm (token, formId) {
}

async function changeElementOrder (token, element1, element2) {
}