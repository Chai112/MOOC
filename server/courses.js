const Db = require('./database');

var courses = new Db.DatabaseTable("Courses",
    "courseId",
    [
        {
        "name": "courseName",
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
        {
        "name": "organizationId",
        "type": "int"
        },
        {
        "name": "courseDescription",
        "type": "varchar(256)"
        },
        {
        "name": "isLive",
        "type": "bit"
        },
]);
courses.init();

async function DO_NOT_RUN_FULL_RESET() {
    await courses.drop();
    await courses.init();
}
DO_NOT_RUN_FULL_RESET();

async function addCourse (token, organizationId, courseOptions) {
    // TODO: check if user CAN add a new course to organization
    courses.insertInto({
        "courseName": courseOptions.courseName,
        "dateCreated": Db.getDatetime(),
        "organizationId": "", // TODO: implement organizationId
        "courseDescription": courseOptions.courseDescription,
        "isLive": 0,
    });
    //courseOptions.courseName;
    //courseOptions.courseDescription;
}

async function changeCourseName (token, courseId, courseName) {
}

async function changeCourseDescription (token, courseId, courseDescription) {
}

async function changeCourseLiveness (token, courseId, isLive) {
}

async function removeCourse (token, courseId, courseOptions) {
    //courseOptions.courseName;
    //courseOptions.courseDescription;
}