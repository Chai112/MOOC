const Db = require('./database');
const Auth = require('./auth');

var organizations = new Db.DatabaseTable("Organizations",
    "organizationId",
    [
        {
        "name": "organizationName",
        "type": "varchar(50)"
        },
        {
        "name": "dateCreated",
        "type": "datetime"
        },
]);
organizations.init();

var organizationPrivileges = new Db.DatabaseTable("OrganizationPrivileges",
    "organizationPrivilegeId",
    [
        {
        "name": "organizationId",
        "type": "int"
        },
        {
        "name": "userId",
        "type": "int"
        },
        {
        "name": "canSeeAnalytics",
        "type": "bit"
        },
        {
        "name": "canEditCourses",
        "type": "bit"
        },
        {
        "name": "canAddNewCourse",
        "type": "bit"
        },
        {
        "name": "isAdmin",
        "type": "bit"
        },
        {
        "name": "isOwner",
        "type": "bit"
        },
]);
organizationPrivileges.init();

var coursePrivileges = new Db.DatabaseTable("CoursePrivileges",
    "coursePrivilegeId",
    [
        {
        "name": "organizationPrivilegeId",
        "type": "int"
        },
        {
        "name": "courseId",
        "type": "int"
        },
        {
        "name": "canSeeAnalytics",
        "type": "bit"
        },
        {
        "name": "canEditCourse",
        "type": "bit"
        },
        {
        "name": "canGiveFeedback",
        "type": "bit"
        },
        {
        "name": "isAdmin",
        "type": "bit"
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

async function createOrganization (token, organizationOptions) {
    let organizationId = await organizations.insertInto({
        "organizationName": organizationOptions.organizationName,
        "dateCreated": Db.getDatetime(),
    });
    let data = await Auth.getUserFromToken(token);
    let username = data[0].userId;

    let privilegeOptions = DEFAULT_OWNER_PRIVILEGES;
    let organizationPrivilegeId = await organizationPrivileges.insertInto({
        "organizationId": organizationId,
        "userId": username,
        "canSeeAnalytics": privilegeOptions.canSeeAnalytics,
        "canEditCourses": privilegeOptions.canEditCourses,
        "canAddNewCourse": privilegeOptions.canAddNewCourse,
        "isAdmin": privilegeOptions.isAdmin,
        "isOwner": privilegeOptions.isOwner,
    });
    return {
        organizationId: organizationId,
        organizationPrivilegesId: organizationPrivilegeId,
    };
}

async function deleteOrganization (token, password, organizationId) {
}

async function assignTeacherToOrganization (assignerToken, assigneeUsername, organizationId, privilegeOptions) {
    // check assigner has privileges
    let assignerUserId = await Auth.getUserFromToken(assignerToken);
    assignerUserId = assignerUserId[0].userId;
    let assignerOrganizationPrivilege = await organizationPrivileges.select({
        organizationId: organizationId,
        userId: assignerUserId,
    });
    if (!assignerOrganizationPrivilege[0].isAdmin) {
        return {message: "assigner does not have permission to assign teacher to organization (must be admin)"};
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
        return {message: "assignee already is assigned. Cannot have more than one assignation"};
    }

    // add the user privileges
    let organizationPrivilegeId = await organizationPrivileges.insertInto({
        organizationId: organizationId,
        userId: assigneeUserId,
        canSeeAnalytics: privilegeOptions.canSeeAnalytics,
        canEditCourses: privilegeOptions.canEditCourses,
        canAddNewCourse: privilegeOptions.canAddNewCourse,
        isAdmin: privilegeOptions.isAdmin,
        isOwner: false,
    });
    return organizationPrivilegeId;
}
module.exports.assignTeacherToOrganization = assignTeacherToOrganization;

async function changeTeacherOrganizationPrivilege (assignerToken, assigneeUsername, privilegeOptions) {
}

async function deassignTeacherFromOrganization (assignerToken, assigneeUsername, organizationId) {
}



async function assignTeacherToCourse (assignerToken, assigneeUsername, courseId, privilegeOptions) {
}

async function changeTeacherCoursePrivilege (assignerToken, assigneeUsername, courseId, privilegeOptions) {
}

async function deassignTeacherFromCourse (assignerToken, assigneeUsername, courseId) {
}



async function getOrganization(organizationId) {
    return await organizations.select({"organizationId": organizationId});
}

async function getOrganizationPrivileges(organizationPrivilegeId) {
    return await organizationPrivileges.select({"organizationPrivilegeId": organizationPrivilegeId});
}

module.exports.createOrganization = createOrganization;
module.exports.getOrganization = getOrganization;
module.exports.getOrganizationPrivileges = getOrganizationPrivileges;
