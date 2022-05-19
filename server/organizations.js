const Db = require('./database');
const Auth = require('./auth');

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
        name: "canSeeAnalytics",
        type: "bit"
        },
        {
        name: "canEditCourses",
        type: "bit"
        },
        {
        name: "canAddNewCourse",
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

const DEFAULT_OWNER_PRIVILEGES = {
    canSeeAnalytics: true,
    canEditCourses: true,
    canAddNewCourse: true,
    isAdmin: true,
    isOwner: true,
}

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

    let organizationPrivilegeId = await assignTeacherToOrganization(token, username, organizationId, DEFAULT_OWNER_PRIVILEGES, true);
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
        canSeeAnalytics: privilegeOptions.canSeeAnalytics,
        canEditCourses: privilegeOptions.canEditCourses,
        canAddNewCourse: privilegeOptions.canAddNewCourse,
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
        canSeeAnalytics: privilegeOptions.canSeeAnalytics,
        canEditCourses: privilegeOptions.canEditCourses,
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

    // delete the user privileges
    await organizationPrivileges.deleteFrom(
    {
        organizationId: organizationId,
        userId: assigneeUserId,
    });
}



module.exports.assignTeacherToCourse = assignTeacherToCourse;
async function assignTeacherToCourse (organizationPrivilegeId, courseId, privilegeOptions) {
    // check assigner has privileges
    let assignerPrivileges = await getTeacherPrivilege(assignerToken, organizationId);
    let assignerIsAdmin = Db.readBool(assignerPrivileges.isAdmin);
    if (!assignerIsAdmin) {
        throw "assigner has insufficient permission to deassign teacher from organization (must be admin)";
    }

    // add the user privileges
    let coursePrivilegeId = await coursePrivileges.insertInto({
        organizationPrivilegeId: organizationPrivilegeId,
        courseId: courseId,
        canSeeAnalytics: privilegeOptions.canSeeAnalytics,
        canEditCourse: privilegeOptions.canEditCourse,
        canGiveFeedback: privilegeOptions.canGiveFeedback,
    });
    return coursePrivilegeId;
}

module.exports.changeTeacherCoursePrivilege = changeTeacherCoursePrivilege;
async function changeTeacherCoursePrivilege (assignerToken, assigneeUsername, courseId, privilegeOptions) {
}

module.exports.deassignTeacherFromCourse = deassignTeacherFromCourse;
async function deassignTeacherFromCourse (assignerToken, assigneeUsername, courseId) {
}



module.exports.getOrganization = getOrganization;
async function getOrganization(organizationId) {
    return await organizations.select({"organizationId": organizationId});
}

module.exports.getOrganizationPrivileges = getOrganizationPrivileges;
async function getOrganizationPrivileges(organizationPrivilegeId) {
    return await organizationPrivileges.select({"organizationPrivilegeId": organizationPrivilegeId});
}

