const Db = require('./database');

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

async function createOrganization (token, organizationId) {
}

async function deleteOrganization (token, password, organizationId) {
}

async function assignTeacherToOrganization (assignerToken, assigneeUsername, organizationId, privilegeOptions) {
}

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