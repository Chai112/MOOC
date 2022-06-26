const Db = require('./database');
const Auth = require('./auth');
const Courses = require('./courses');

var organizations = new Db.DatabaseTable("Organizations",
    "organizationId",
    [
        {
        name: "organizationName",
        type: "varchar(50)"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
]);
organizations.init();

var organizationPrivileges = new Db.DatabaseTable("OrganizationPrivileges",
    "organizationPrivilegeId",
    [
        {
        name: "organizationId",
        type: "int"
        },
        {
        name: "userId",
        type: "int"
        },
        {
        name: "canSeeAllAnalytics",
        type: "bit"
        },
        {
        name: "canEditAllCourses",
        type: "bit"
        },
        {
        name: "canAddNewCourse",
        type: "bit"
        },
        {
        name: "canChangeCourseLiveness",
        type: "bit"
        },
        {
        name: "isAdmin",
        type: "bit"
        },
        {
        name: "isOwner",
        type: "bit"
        },
]);
organizationPrivileges.init();

var coursePrivileges = new Db.DatabaseTable("CoursePrivileges",
    "coursePrivilegeId",
    [
        {
        name: "organizationPrivilegeId",
        type: "int"
        },
        {
        name: "courseId",
        type: "int"
        },
        {
        name: "canSeeAnalytics",
        type: "bit"
        },
        {
        name: "canEditCourse",
        type: "bit"
        },
        {
        name: "canGiveFeedback",
        type: "bit"
        },
]);
coursePrivileges.init();

const DEFAULT_ORGANIZATION_OWNER_PRIVILEGES = {
    canSeeAllAnalytics: true,
    canEditAllCourses: true,
    canAddNewCourse: true,
    canChangeCourseLiveness: true,
    isAdmin: true,
    isOwner: true,
};

//module.exports.DO_NOT_RUN_FULL_RESET = DO_NOT_RUN_FULL_RESET;
async function DO_NOT_RUN_FULL_RESET() {
    await organizations.drop();
    await organizations.init();
    await organizationPrivileges.drop();
    await organizationPrivileges.init();
    await coursePrivileges.drop();
    await coursePrivileges.init();
}

module.exports.createOrganization = createOrganization;
async function createOrganization (token, organizationOptions) {
    let organizationId = await organizations.insertInto({
        "organizationName": organizationOptions.organizationName,
        "dateCreated": Db.getDatetime(),
    });

    let data = await Auth.getUserFromToken(token);
    let username = data[0].username;

    let organizationPrivilegeId = await assignTeacherToOrganization(token, username, organizationId, DEFAULT_ORGANIZATION_OWNER_PRIVILEGES, true);
    return {
        organizationId: organizationId,
        organizationPrivilegesId: organizationPrivilegeId,
    };
}

module.exports.deleteOrganization = deleteOrganization;
async function deleteOrganization (token, organizationId) {
    // check assigner has privileges
    let assignerPrivileges = await getTeacherPrivilege(token, organizationId);
    let assignerIsOwner = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsOwner) {
        throw "assigner has insufficient permission to delete organization (must be admin)";
    }

    // delete course privileges
    let data = await organizationPrivileges.select({organizationId: organizationId});
    for (var i = 0; i < data.length; i++) {
        data2 = await coursePrivileges.deleteFrom({
            organizationPrivilegeId: data[i].organizationPrivilegeId,
        });
    }

    // delete courses
    await Courses.deleteAllCoursesFromOrganization(organizationId);

    // delete the user privileges
    await organizationPrivileges.deleteFrom(
    {
        organizationId: organizationId,
    });

    // delete the organization
    await organizations.deleteFrom({
        organizationId: organizationId,
    })
}

module.exports.getTeacherPrivilege = getTeacherPrivilege;
async function getTeacherPrivilege(assignerToken, organizationId) {
    let assignerUserId = await Auth.getUserFromToken(assignerToken);
    assignerUserId = assignerUserId[0].userId;
    let assignerOrganizationPrivilege = await organizationPrivileges.select({
        organizationId: organizationId,
        userId: assignerUserId,
    });
    if (assignerOrganizationPrivilege.length === 0) {
        throw "assigner not part of organization";
    }
    return assignerOrganizationPrivilege[0];
}

module.exports.assignTeacherToOrganization = assignTeacherToOrganization;
async function assignTeacherToOrganization (assignerToken, assigneeUsername, organizationId, privilegeOptions, overrideSafety = false) {
    if (!overrideSafety) {
        // check assigner has privileges
        let assignerPrivileges = await getTeacherPrivilege(assignerToken, organizationId);
        let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
        if (!assignerIsAdmin) {
            throw "assigner has insufficient permission to assign teacher to organization (must be admin)";
        }
    }

    // get assignee userid from username
    let assigneeUserId = await Auth.getUserFromUsername(assigneeUsername);
    assigneeUserId = assigneeUserId[0].userId;

    // check if assignee has already been assigned
    let assigneeOrganizaionPrivilege = await organizationPrivileges.select({
        organizationId: organizationId,
        userId: assigneeUserId,
    });
    if (assigneeOrganizaionPrivilege.length > 0) {
        throw "assignee already is assigned. Cannot have more than one assignation";
    }

    // add the user privileges
    let organizationPrivilegeId = await organizationPrivileges.insertInto({
        organizationId: organizationId,
        userId: assigneeUserId,
        canSeeAllAnalytics: privilegeOptions.canSeeAllAnalytics,
        canEditAllCourses: privilegeOptions.canEditAllCourses,
        canAddNewCourse: privilegeOptions.canAddNewCourse,
        canChangeCourseLiveness: privilegeOptions.canChangeCourseLiveness,
        isAdmin: privilegeOptions.isAdmin,
        isOwner: privilegeOptions.isOwner && overrideSafety,
    });
    return organizationPrivilegeId;
}

module.exports.changeTeacherOrganizationPrivilege = changeTeacherOrganizationPrivilege;
async function changeTeacherOrganizationPrivilege (assignerToken, assigneeUsername, organizationId, privilegeOptions) {
    // check assigner has privileges
    let assignerPrivileges = await getTeacherPrivilege(assignerToken, organizationId);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsAdmin) {
        throw "assigner has insufficient permission to change teacher's permission from organization (must be admin)";
    }

    // get assignee userid from username
    let assigneeUserId = await Auth.getUserFromUsername(assigneeUsername);
    assigneeUserId = assigneeUserId[0].userId;

    // add the user privileges
    await organizationPrivileges.update(
    {
        organizationId: organizationId,
        userId: assigneeUserId,
    },
    {
        canSeeAllAnalytics: privilegeOptions.canSeeAllAnalytics,
        canEditAllCourses: privilegeOptions.canEditAllCourses,
        canAddNewCourse: privilegeOptions.canAddNewCourse,
        isAdmin: privilegeOptions.isAdmin,
    });
}

module.exports.deassignTeacherFromOrganization = deassignTeacherFromOrganization;
async function deassignTeacherFromOrganization (assignerToken, assigneeUsername, organizationId) {
    // check assigner has privileges
    let assignerPrivileges = await getTeacherPrivilege(assignerToken, organizationId);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsAdmin) {
        throw "assigner has insufficient permission to deassign teacher from organization (must be admin)";
    }

    // get assignee userid from username
    let assigneeUserId = await Auth.getUserFromUsername(assigneeUsername);
    assigneeUserId = assigneeUserId[0].userId;

    // revoke the user's course privileges
    let organizationPrivilege = await organizationPrivileges.select({
        organizationId: organizationId
    });
    let organizationPrivilegeId = organizationPrivilege[0].organizationPrivilegeId;
    await coursePrivileges.deleteFrom({
        organizationPrivilegeId: organizationPrivilegeId
    });

    // delete the user's privileges
    await organizationPrivileges.deleteFrom(
    {
        organizationId: organizationId,
        userId: assigneeUserId,
    });
}



module.exports.assignTeacherToCourse = assignTeacherToCourse;
async function assignTeacherToCourse (assignerToken, assigneeUsername, courseId, privilegeOptions, overrideSafety = false) {
    // firstly, we must get organizationId from courseId
    let courseData = await Courses.getCourse(courseId);
    let organizationId = courseData[0].organizationId;

    // check assigner has privileges
    let assignerPrivileges = await getTeacherPrivilege(assignerToken, organizationId);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!(assignerIsAdmin || overrideSafety)) {
        throw "assigner has insufficient permission to deassign teacher from organization (must be admin)";
    }

    // get assignee's organizationPrivilegeId
    let assigneeUser = await Auth.getUserFromUsername(assigneeUsername);
    assigneeUserId = assigneeUser[0].userId;
    let assigneeOrganizationPrivilege = await organizationPrivileges.select({
        organizationId: organizationId,
        userId: assigneeUserId,
    });
    if (assigneeOrganizationPrivilege.length === 0) {
        throw "assignee must be a part of the organization to be assigned to a course";
    }
    let assigneeOrganizationPrivilegeId = assigneeOrganizationPrivilege[0].organizationPrivilegeId;

    // add the user privileges
    let coursePrivilegeId = await coursePrivileges.insertInto({
        organizationPrivilegeId: assigneeOrganizationPrivilegeId,
        courseId: courseId,
        canSeeAnalytics: privilegeOptions.canSeeAnalytics,
        canEditCourse: privilegeOptions.canEditCourse,
        canGiveFeedback: privilegeOptions.canGiveFeedback,
    });
    return coursePrivilegeId;
}

module.exports.changeTeacherCoursePrivilege = changeTeacherCoursePrivilege;
async function changeTeacherCoursePrivilege (assignerToken, assigneeUsername, courseId, privilegeOptions) {
    // firstly, we must get organizationId from courseId
    let courseData = await Courses.getCourse(courseId);
    let organizationId = courseData[0].organizationId;
     
    // check assigner has privileges
    let assignerPrivileges = await getTeacherPrivilege(assignerToken, organizationId);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsAdmin) {
        throw "assigner has insufficient permission to deassign teacher from organization (must be admin)";
    }

    // get assignee's organizationPrivilegeId
    let assigneeUser = await Auth.getUserFromUsername(assigneeUsername);
    assigneeUserId = assigneeUser[0].userId;
    let assigneeOrganizationPrivilege = await organizationPrivileges.select({
        organizationId: organizationId,
        userId: assigneeUserId,
    });
    let assigneeOrganizationPrivilegeId = assigneeOrganizationPrivilege[0].organizationPrivilegeId;


    await coursePrivileges.update(
        {
            organizationPrivilegeId: assigneeOrganizationPrivilegeId,
            courseId: courseId,
        },
        {
            canSeeAnalytics: privilegeOptions.canSeeAnalytics,
            canEditCourse: privilegeOptions.canEditCourse,
            canGiveFeedback: privilegeOptions.canGiveFeedback,
        }
    );
}

module.exports.deassignTeacherFromCourse = deassignTeacherFromCourse;
async function deassignTeacherFromCourse (assignerToken, assigneeUsername, courseId) {
    // firstly, we must get organizationId from courseId
    let courseData = await Courses.getCourse(courseId);
    let organizationId = courseData[0].organizationId;
     
    // check assigner has privileges
    let assignerPrivileges = await getTeacherPrivilege(assignerToken, organizationId);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsAdmin) {
        throw "assigner has insufficient permission to deassign teacher from organization (must be admin)";
    }

    // get assignee's organizationPrivilegeId
    let assigneeUser = await Auth.getUserFromUsername(assigneeUsername);
    assigneeUserId = assigneeUser[0].userId;
    let assigneeOrganizationPrivilege = await organizationPrivileges.select({
        organizationId: organizationId,
        userId: assigneeUserId,
    });
    let assigneeOrganizationPrivilegeId = assigneeOrganizationPrivilege[0].organizationPrivilegeId;

    // delete course privileges
    await coursePrivileges.deleteFrom(
        {
            organizationPrivilegeId: assigneeOrganizationPrivilegeId,
            courseId: courseId,
        }
    );
}

// used only for when course is being deleted
module.exports.deassignAllTeachersFromCourse = deassignAllTeachersFromCourse;
async function deassignAllTeachersFromCourse (courseId) {
    // delete course privileges
    await coursePrivileges.deleteFrom({ courseId: courseId, });
}



module.exports.getOrganization = getOrganization;
async function getOrganization(organizationId) {
    return await organizations.select({"organizationId": organizationId});
}

module.exports.getOrganizationPrivileges = getOrganizationPrivileges;
async function getOrganizationPrivileges(organizationPrivilegeId) {
    return await organizationPrivileges.select({"organizationPrivilegeId": organizationPrivilegeId});
}

module.exports.getCoursePrivilege = getCoursePrivilege;
async function getCoursePrivilege(coursePrivilegeId) {
    return await coursePrivileges.select({coursePrivilegeId: coursePrivilegeId});
}

module.exports.getCoursePrivilegesForCourseAndUser = getCoursePrivilegesForCourseAndUser;
async function getCoursePrivilegesForCourseAndUser(courseId, organizationId, userId) {
    let organizationPrivilege = await organizationPrivileges.select({
        userId: userId,
        organizationId: organizationId,
    });
    if (organizationPrivilege.length === 0) {
        throw "assigner not part of organization";
    }
    let organizationPrivilegeId = organizationPrivilege[0].organizationPrivilegeId;

    let coursePrivilege = await coursePrivileges.select({
        courseId: courseId,
        organizationPrivilegeId: organizationPrivilegeId,
    });
    if (coursePrivilege.length === 0) {
        throw "assignee not part of course";
    }
    return coursePrivilege[0];
}

module.exports.getAllCoursePrivilegesForOrganization = getAllCoursePrivilegesForOrganization;
async function getAllCoursePrivilegesForOrganization(organizationId) {
    let coursePrivilegesOutput = [];
    let data = await organizationPrivileges.select({organizationId: organizationId});
    for (var i = 0; i < data.length; i++) {
        data2 = await coursePrivileges.select({
            organizationPrivilegeId: data[i].organizationPrivilegeId,
        });
        if (data2.length !== 0) {
            coursePrivilegesOutput.push(data2);
        }
    }
    return coursePrivilegesOutput;
}

module.exports.getOrganizationsForUser = getOrganizationsForUser;
async function getOrganizationsForUser(token) {
    let user = await Auth.getUserFromToken(token);
    let userId = user[0].userId;

    let organizationPrivilegesOfUser = await organizationPrivileges.select({
        userId: userId,
    });
    let organizationIds = [];
    for (var i = 0; i < organizationPrivilegesOfUser.length; i++) {
        let organizationId = organizationPrivilegesOfUser[i].organizationId;
        let organization = await organizations.select({organizationId: organizationId});

        organizationIds.push({
            organizationId: organizationId,
            organizationName: organization[0].organizationName,
        });
    }
    return organizationIds;
}