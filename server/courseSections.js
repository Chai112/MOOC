const Db = require('./database');
const Auth = require('./auth');
const Org = require('./organizations');
const Courses = require('./courses');
const CourseElements = require('./courseElements');

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
        "name": "sectionOrder",
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
    let sectionOrder = await _getNextSectionOrder(courseId);

    let courseSectionId = await courseSections.insertInto({
        courseId: courseId,
        courseSectionName: courseSectionOptions.courseSectionName,
        dateCreated: Db.getDatetime(),
        dateModified: Db.getDatetime(),
        sectionOrder: sectionOrder,
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

    // remove element order
    let courseSection = await courseSections.select({ courseSectionId: courseSectionId });
    await _removeSectionOrder(courseSection[0].sectionOrder, courseSection[0].courseId);
    await CourseElements.removeAllCourseElementsFromCourseSection(courseSection[0].courseSectionId);

    courseSections.deleteFrom({ courseSectionId: courseSectionId, });
}

module.exports.removeAllCourseSectionsFromCourse = removeAllCourseSectionsFromCourse;
async function removeAllCourseSectionsFromCourse(courseId) {
    // clean all course sections
    let data = await courseSections.select({ courseId:  courseId });
    for (var i = 0; i < data.length; i++) {
        await CourseElements.removeAllCourseElementsFromCourseSection(data[i].courseSectionId);
    }
    await courseSections.deleteFrom({ courseId: courseId, });
}

module.exports.getAllCourseSectionsFromCourse = getAllCourseSectionsFromCourse;
async function getAllCourseSectionsFromCourse(courseId) {
    return await courseSections.select({ courseId: courseId });
}

module.exports.getCourseHierarchy = getCourseHierarchy;
async function getCourseHierarchy(token, courseId) {
    await assertUserCanViewCourse(token, courseId);
    let output = await courseSections.select({ courseId: courseId });
    for (let i = 0; i < output.length; i++) {
        output[i].children = await CourseElements.getAllElementsFromCourseSection(output[i].courseSectionId);
    }
    return output;
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
    // if no errors caused by above, should be OK
}

async function _getNextSectionOrder (courseId) {
    let sectionOrder = await courseSections.selectMax("sectionOrder", { courseId: courseId });

    // check if even any elements exists
    if (sectionOrder.sectionOrder === null) {
        return 0;
    }
    return sectionOrder.sectionOrder + 1;
}

async function _removeSectionOrder (sectionOrder, courseId) {
    let cs = await courseSections.select({courseId: courseId});
    for (let i = 0; i < cs.length; i++) {
        if (cs[i].sectionOrder > sectionOrder) {
            await courseSections.update(
                { courseSectionId: cs[i].courseSectionId },
                { sectionOrder: cs[i].sectionOrder - 1 }
            );
        }
    }
}

// 0: [ Alice ]
// 1: [ Bob ]
// 2: [ Charlie ]
// 3: [ Derek ]
// 4: [ Franky ]
// move Bob to index 3 (toSectionOrder = 3, currentSectionOrder = 1)
// 0: [ Alice ]
// 1: [ Charlie ]
// 2: [ Derek ]
// 3: [ Bob ]
// 4: [ Franky ]
// 
// step 1: remove the currentSectionOrder
// step 2: anything above or equal toSectionOrder, shift up by one
// step 3: insert into

module.exports.moveCourseSection = moveCourseSection;
async function moveCourseSection(courseSectionId, toSectionOrder) {
    let courseSection = (await courseSections.select({courseSectionId: courseSectionId}))[0];
    let currentSectionOrder = courseSection.sectionOrder;
    let courseId = courseSection.courseId;

    // step 1: remove the currentSectionOrder
    await _removeSectionOrder(currentSectionOrder, courseId);

    // step 2: anything above toSectionOrder, shift up by one
    let cs = await courseSections.select({courseId: courseId});
    for (let i = 0; i < cs.length; i++) {
        if (cs[i].sectionOrder >= toSectionOrder) {
            await courseSections.update(
                { courseSectionId: cs[i].courseSectionId },
                { sectionOrder: cs[i].sectionOrder + 1 }
            );
        }
    }

    // step 3: insert into
    await courseSections.update(
        { courseSectionId: courseSectionId },
        { sectionOrder: toSectionOrder }
    );
}
