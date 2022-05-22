const Db = require('./database');
const Auth = require('./auth');
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

const DEFAULT_COURSE_OWNER_PRIVILEGES = {
    canSeeAnalytics: true,
    canEditCourse: true,
    canGiveFeedback: true,
};

async function DO_NOT_RUN_FULL_RESET() {
    await courses.drop();
    await courses.init();
}
DO_NOT_RUN_FULL_RESET();

module.exports.addCourse = addCourse;
async function addCourse (token, organizationId, courseOptions) {
    // check assigner has privileges
    let assignerPrivileges = await Org.getTeacherPrivilege(token, organizationId);
    let assignerCanAddNewCourse = Db.readBool(assignerPrivileges.canAddNewCourse);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!(assignerCanAddNewCourse || assignerIsAdmin)) {
        throw "assigner has insufficient permission";
    }

    // add course
    let courseId = await courses.insertInto({
        courseName: courseOptions.courseName,
        dateCreated: Db.getDatetime(),
        organizationId: organizationId, // TODO: implement organizationId
        courseDescription: courseOptions.courseDescription,
        isLive: 0,
    });

    // get username of assigner
    let data = await Auth.getUserFromToken(token);
    let username = data[0].username;

    // assign course creator to course
    let coursePrivilegeId = await Org.assignTeacherToCourse(token, username, courseId, DEFAULT_COURSE_OWNER_PRIVILEGES, true);
    return {
        courseId: courseId,
        coursePrivilegeId: coursePrivilegeId,
    };
}

module.exports.getCourse = getCourse;
async function getCourse (courseId) {
    return await courses.select({courseId: courseId});
}

module.exports.changeCourseOptions = changeCourseOptions;
async function changeCourseOptions (token, courseId, courseOptions) {
    // get organizationId
    let courseData = await courses.select({courseId: courseId});
    let organizationId = courseData[0].organizationId;

    // check assigner has privileges
    let privileges = await Org.getTeacherPrivilege(token, organizationId);
    let canEditAllCourses = Db.readBool(privileges.canEditAllCourses);
    let isAdmin = Db.readBool(privileges.isAdmin);

    // get coursePrivilege of assigner to check if they can edit this course
    let user = await Auth.getUserFromToken(token);
    userId = user[0].userId;
    let coursePrivileges = await Org.getCoursePrivilegesForCourseAndUser(courseId, organizationId, userId);
    let canEditCourse = Db.readBool(coursePrivileges.canEditCourse);

    if (!(canEditAllCourses || isAdmin || canEditCourse)) {
        throw "assigner has insufficient permission";
    }

    await courses.update(
        { courseId: courseId },
        {
            courseName: courseOptions.courseName,
            courseDescription: courseOptions.courseDescription,
            dateModified: Db.getDatetime(),
        }
    );
}

module.exports.changeCourseLiveness = changeCourseLiveness;
async function changeCourseLiveness (token, courseId, courseLiveness) {
    // get organizationId
    let courseData = await courses.select({courseId: courseId});
    let organizationId = courseData[0].organizationId;

    // check assigner has privileges
    let privileges = await Org.getTeacherPrivilege(token, organizationId);
    let canChangeCourseLiveness = Db.readBool(privileges.canChangeCourseLiveness);
    let isAdmin = Db.readBool(privileges.isAdmin);

    if (!(canChangeCourseLiveness || isAdmin)) {
        throw "assigner has insufficient permission";
    }

    await courses.update(
        { courseId: courseId },
        {
            isLive: courseLiveness,
            dateModified: Db.getDatetime(),
        }
    );
}

module.exports.removeCourse = removeCourse;
async function removeCourse (token, courseId) {
    // get organizationId
    let courseData = await courses.select({courseId: courseId});
    let organizationId = courseData[0].organizationId;

    // check assigner has privileges
    let assignerPrivileges = await Org.getTeacherPrivilege(token, organizationId);
    let assignerHasPerms = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerHasPerms) {
        throw "assigner has insufficient permission to remove course (must be admin)";
    }

    // remove all privileges
    await Org.deassignAllTeachersFromCourse(courseId);

    // remove all subscriptions

    // remove course
    await courses.deleteFrom({ courseId: courseId });
}