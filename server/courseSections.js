const Db = require('./database');

var courseSections = new Db.DatabaseTable("CourseSections",
    "courseSectionId",
    [
        {
        "name": "courseSectionName",
        "type": "varchar(50)"
        },
        {
        "name": "dateCreated",
        "type": "datetime"
        },
        {
        "name": "dateModified",
        "type": "datetime"
        },
]);
courseSections.init();

async function addCourseSection (token, courseSectionName) {
}

async function removeCourseSection (token, courseSectionId) {
}


