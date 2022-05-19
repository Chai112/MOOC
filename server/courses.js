const Db = require('./database');
const Org = require('./organizations');

var courses = new Db.DatabaseTable("Courses",
    "courseId",
    [
        {
        name: "courseName",
        type: "varchar(50)"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "dateModified",
        type: "datetime"
        },
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "courseDescription",
        type: "varchar(256)"
        },
        {
        name: "isLive",
        type: "bit"
        },
]);
courses.init();

async function DO_NOT_RUN_FULL_RESET() {
    await courses.drop();
    await courses.init();
}
DO_NOT_RUN_FULL_RESET();

module.exports.addCourse = addCourse;
async function addCourse (token, organizationId, courseOptions) {
    // check assigner has privileges
    let assignerPrivileges = await Org.getTeacherPrivilege(token, organizationId);
    let assignerHasPerms = Db.readBool(assignerPrivileges.canAddNewCourse);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!(assignerHasPerms || assignerIsAdmin)) {
        throw "assigner has insufficient permission";
    }

    let courseId = await courses.insertInto({
        courseName: courseOptions.courseName,
        dateCreated: Db.getDatetime(),
        organizationId: organizationId, // TODO: implement organizationId
        courseDescription: courseOptions.courseDescription,
        isLive: 0,
    });
    return courseId;
}

module.exports.getCourse = getCourse;
async function getCourse (courseId) {
    return await courses.select({courseId: courseId});
}

async function changeCourseOptions (token, courseId, courseName) {
}

async function removeCourse (token, courseId, courseOptions) {
    // check assigner has privileges
    let assignerPrivileges = await Org.getTeacherPrivilege(token, organizationId);
    let assignerHasPerms = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerHasPerms) {
        throw "assigner has insufficient permission to remove course (must be admin)";
    }

    // remove all privileges
    // remove course
}