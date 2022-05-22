const Db = require('./database');
const Auth = require('./auth');
const Org = require('./organizations');
const Courses = require('./courses');

var courseSections = new Db.DatabaseTable("CourseSections",
    "courseSectionId",
    [
        {
        "name": "courseId",
        "type": "int"
        },
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

module.exports.DO_NOT_RUN_FULL_RESET = DO_NOT_RUN_FULL_RESET;
async function DO_NOT_RUN_FULL_RESET() {
    await courseSections.drop();
    await courseSections.init();
}

module.exports.addCourseSection = addCourseSection;
async function addCourseSection (token, courseId, courseSectionOptions) {
    // check auth
    await assertUserCanEditCourse(token, courseId);

    let courseSectionId = await courseSections.insertInto({
        courseId: courseId,
        courseSectionName: courseSectionOptions.courseSectionName,
        dateCreated: Db.getDatetime(),
        dateModified: Db.getDatetime(),
    });
    return courseSectionId;
}

module.exports.changeCourseSection = changeCourseSection;
async function changeCourseSection (token, courseSectionId, courseSectionOptions) {
    // check auth
    let courseSection = await courseSections.select({ courseSectionId: courseSectionId });
    let courseId = courseSection[0].courseId;
    await assertUserCanEditCourse(token, courseId);

    await courseSections.update(
        { courseSectionId: courseSectionId, },
        { courseSectionName: courseSectionOptions.courseSectionName, }
    );
}

module.exports.removeCourseSection = removeCourseSection;
async function removeCourseSection (token, courseSectionId) {
    // check auth
    let courseSection = await courseSections.select({ courseSectionId: courseSectionId });
    let courseId = courseSection[0].courseId;
    await assertUserCanEditCourse(token, courseId);

    courseSections.deleteFrom({ courseSectionId: courseSectionId, });
}

module.exports.getAllCourseSectionsFromCourse = getAllCourseSectionsFromCourse;
async function getAllCourseSectionsFromCourse(courseId) {
    return await courseSections.select({ courseId: courseId });
}
module.exports.getCourseSection = getCourseSection;
async function getCourseSection(courseSectionId) {
    return await courseSections.select({ courseSectionId: courseSectionId });
}

async function assertUserCanEditCourse(token, courseId) {
    // get organizationId
    let courseData = await Courses.getCourse(courseId);
    let organizationId = courseData[0].organizationId;

    let user = await Auth.getUserFromToken(token);
    userId = user[0].userId;
    let coursePrivileges = await Org.getCoursePrivilegesForCourseAndUser(courseId, organizationId, userId);
    let canEditCourse = Db.readBool(coursePrivileges.canEditCourse);
    if (!canEditCourse) {
        throw `assigner has insufficient permission to edit course ${courseId}`;
    }
}