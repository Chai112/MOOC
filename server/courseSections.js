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
        {
        "name": "elementOrder",
        "type": "int"
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

    // find element order
    let elementOrder = 0;

    let courseSectionId = await courseSections.insertInto({
        courseId: courseId,
        courseSectionName: courseSectionOptions.courseSectionName,
        dateCreated: Db.getDatetime(),
        dateModified: Db.getDatetime(),
        elementOrder: elementOrder,
    });
    return courseSectionId;
}

module.exports.changeCourseSection = changeCourseSection;
async function changeCourseSection (token, courseSectionId, courseSectionOptions) {
    // check auth
    await assertUserCanEditCourseSection(token, courseSectionId);

    await courseSections.update(
        { courseSectionId: courseSectionId, },
        { courseSectionName: courseSectionOptions.courseSectionName, }
    );
}

module.exports.removeCourseSection = removeCourseSection;
async function removeCourseSection (token, courseSectionId) {
    // check auth
    await assertUserCanEditCourseSection(token, courseSectionId);

    courseSections.deleteFrom({ courseSectionId: courseSectionId, });
}

module.exports.removeAllCourseSectionsFromCourse = removeAllCourseSectionsFromCourse;
async function removeAllCourseSectionsFromCourse(courseId) {
    await courseSections.deleteFrom({ courseId: courseId, });
}

module.exports.moveCourseSection = moveCourseSection;
// 0: [ Alice ]
// 1: [ Bob ]
// 2: [ Charlie ]
// 3: [ Derek ]
// move alice to index 2 (move index [alice + 1] to [place alice will go to] down by one)
// 0: [ Bob ]
// 1: [ Charlie ]
// 2: [ Alice ]
// 3: [ Derek ]

async function moveCourseSection(courseSectionId, toElementOrder) {
    throw "not yet implemented";
}

module.exports.getAllCourseSectionsFromCourse = getAllCourseSectionsFromCourse;
async function getAllCourseSectionsFromCourse(courseId) {
    return await courseSections.select({ courseId: courseId });
}

module.exports.getCourseHierarchy = getCourseHierarchy;
async function getCourseHierarchy(token, courseId) {
    await assertUserCanViewCourse(token, courseId);
    return await courseSections.select({ courseId: courseId });
}

module.exports.getCourseSection = getCourseSection;
async function getCourseSection(courseSectionId) {
    return await courseSections.select({ courseSectionId: courseSectionId });
}

module.exports.assertUserCanEditCourseSection = assertUserCanEditCourseSection;
async function assertUserCanEditCourseSection(token, courseSectionId) {
    let courseSection = await courseSections.select({ courseSectionId: courseSectionId });
    let courseId = courseSection[0].courseId;
    await assertUserCanEditCourse(token, courseId);
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
        throw `assigner has insufficient permission`;
    }
}

async function assertUserCanViewCourse(token, courseId) {
    // get organizationId
    let courseData = await Courses.getCourse(courseId);
    let organizationId = courseData[0].organizationId;

    let user = await Auth.getUserFromToken(token);
    userId = user[0].userId;
    await Org.getCoursePrivilegesForCourseAndUser(courseId, organizationId, userId);
    return true;
}