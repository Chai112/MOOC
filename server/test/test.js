const Db = require('../database');
const Auth = require('../auth');
const Org = require('../organizations');
const Token = require('../token');

var assert = require('assert');

describe('Database', function () {
    it('should connect to the SQL server', async function () {
        Db.sqlConnect();
    });
    let testingTable;
    it('should initialize & clear table', async function () {
        testingTable = new Db.DatabaseTable("Tests",
            "testId",
            [
                {
                name: "username",
                type: "varchar(50)"
                },
                {
                name: "password",
                type: "varchar(32)"
                }
            ]
        );
        await testingTable.init();
        await testingTable.drop();
        await testingTable.init();

        // check
        let data = await testingTable.select();
        assert.equal(data.length, 0);
    });
    it('should insert into table', async function () {
        await testingTable.insertInto(
        {
            username: "cat",
            password: "bat"
        });
        await testingTable.insertInto(
        {
            username: "cat",
            password: "mat"
        });

        // check
        let data = await testingTable.select();
        assert.equal(data.length, 2);
        assert.equal(data[0].testId, 1);
        assert.equal(data[0].username, "cat");
        assert.equal(data[0].password, "bat");
        assert.equal(data[1].testId, 2);
        assert.equal(data[1].username, "cat");
        assert.equal(data[1].password, "mat");
    });
    it('should delete from table', async function () {
        await testingTable.deleteFrom(
            {password: "mat"},
        );

        // check
        let data = await testingTable.select();
        assert.equal(data.length, 1);
        assert.equal(data[0].testId, 1);
        assert.equal(data[0].username, "cat");
        assert.equal(data[0].password, "bat");
    });
    it('should update table', async function () {
        //console.log(data);
        await testingTable.update(
            // where...
            {username: "cat"},
            // set entry to...
            {
                username: "bat",
                password: "nat",
            }
        );

        // check
        let data = await testingTable.select();
        assert.equal(data.length, 1);
        assert.equal(data[0].testId, 1);
        assert.equal(data[0].username, "bat");
        assert.equal(data[0].password, "nat");
    });
});

describe('Authentication', function () {
    let randomName = Token.generateToken();
    let token = "";
    it('should create a user', async function () {
        try {
            token = await Auth.loginUser("test", "password");
            await Auth.deleteUser(token, "password");
        } catch {

        }
        token = await Auth.registerUser("test", "password", "test@test.com", randomName, "lastname");

        let data = await Auth.getUserFromToken(token);
        let user = data[0];
        assert.equal(user.username, "test");
        assert.equal(user.firstName, randomName);
    });
    it('should NOT create duplicate user', async function () {
        await assert.rejects(
            async function () { 
                await Auth.registerUser("test", "password", "test@test.com", "firstname", "lastname");
            }
        );
    });
    it('should login user', async function () {
        token = await Auth.loginUser("test", "password");

        let data = await Auth.getUserFromToken(token);
        let user = data[0];
        assert.equal(user.firstName, randomName);
    });
    it('should NOT login user with wrong username', async function () {
        await assert.rejects(
            async function () { 
                await Auth.loginUser(`test_${randomName}`, "password");
            }
        );
    });
    it('should logout user', async function () {
        await Auth.logoutUser(token);
        let data = await Auth.getUserFromToken(token);
        assert.equal(data.length, "0");
    });
    it('should delete user', async function () {
        token = await Auth.loginUser("test", "password");
        await Auth.deleteUser(token, "password");

        let data = await Auth.getUserFromToken(token);
        assert.equal(data.length, "0");

        // login should fail
        await assert.rejects(
            async function () { 
                await Auth.loginUser("test", "password");
            }
        );
    });
});

describe('Organizations', function () {
    let randomName = Token.generateToken();
    let orgId;
    let orgPrivId;
    let tokenA;
    let tokenB;
    it('add organization', async function () {
        try {
            tokenA = await Auth.loginUser("test", "password");
            await Auth.deleteUser(tokenA, "password");
        } catch {
        }
        tokenA = await Auth.registerUser("test", "password", "test@test.com", randomName, "lastname");
        let orgData = await Org.createOrganization(tokenA, {
            organizationName: `TestOrg${randomName}`
        });
        orgId = orgData.organizationId;
        orgPrivId = orgData.organizationPrivilegesId;
        let data = await Org.getOrganization(orgId);
        assert.equal(data[0].organizationName, `TestOrg${randomName}`);
    });
    it('add organization adds the creator as owner', async function () {
        let dataOrgPriv = await Org.getOrganizationPrivileges(orgPrivId);
        assert.equal(dataOrgPriv.length, 1);
        assert.equal(Db.readBool(dataOrgPriv[0].isOwner), true);
        let dataOrgPrivUser = await Auth.getUserFromUserId(dataOrgPriv[0].userId);
        assert.equal(dataOrgPrivUser[0].username, "test");
    });
    it('add assign new user to organization', async function () {
        try {
            tokenB = await Auth.loginUser("test2", "password");
            await Auth.deleteUser(tokenB, "password");
        } catch {
        }
        tokenB = await Auth.registerUser("test2", "password", "test@test.com", `a_${randomName}`, "lastname");
        orgPrivId = await Org.assignTeacherToOrganization(tokenA, "test2", orgId, {
            canSeeAnalytics: false,
            canEditCourses: false,
            canAddNewCourse: true,
            isAdmin: true,
        });
        let dataOrgPriv = await Org.getOrganizationPrivileges(orgPrivId);
        assert.equal(dataOrgPriv.length, 1);
        assert.equal(Db.readBool(dataOrgPriv[0].isOwner), false);

    });
});

describe('Template', function () {
    it('', async function () {
    });
});