const Db = require('../database');
const Auth = require('../auth');

var assert = require('assert');

describe('Basic Suite', function () {
    it('should connect to the SQL server', async function () {
        Db.sqlConnect();
    });
    let testingTable;
    it('should initialize & clear table', async function () {
        testingTable = new Db.DatabaseTable("Tests",
            "test_id",
            [
                {
                "name": "username",
                "type": "varchar(50)"
                },
                {
                "name": "password",
                "type": "varchar(32)"
                }
            ]
        );
        await testingTable.init();
        await testingTable.dropTable();
        testingTable = new Db.DatabaseTable("Tests",
            "test_id",
            [
                {
                "name": "username",
                "type": "varchar(50)"
                },
                {
                "name": "password",
                "type": "varchar(32)"
                }
            ]
        );
        await testingTable.init();

        // check
        let data = await testingTable.selectTable();
        assert.equal(data.length, 0);
    });
    it('should insert into table', async function () {
        await testingTable.insertIntoTable(
        {
            username: "cat",
            password: "bat"
        });
        await testingTable.insertIntoTable(
        {
            username: "cat",
            password: "mat"
        });

        // check
        let data = await testingTable.selectTable();
        assert.equal(data.length, 2);
        assert.equal(data[0].test_id, 1);
        assert.equal(data[0].username, "cat");
        assert.equal(data[0].password, "bat");
        assert.equal(data[1].test_id, 2);
        assert.equal(data[1].username, "cat");
        assert.equal(data[1].password, "mat");
    });
    it('should delete from table', async function () {
        await testingTable.deleteFromTable(
            {password: "mat"},
        );

        // check
        let data = await testingTable.selectTable();
        assert.equal(data.length, 1);
        assert.equal(data[0].test_id, 1);
        assert.equal(data[0].username, "cat");
        assert.equal(data[0].password, "bat");
    });
    it('should update table', async function () {
        //console.log(data);
        await testingTable.updateTable(
            // where...
            {username: "cat"},
            // set entry to...
            {
                username: "bat",
                password: "nat",
            }
        );

        // check
        let data = await testingTable.selectTable();
        assert.equal(data.length, 1);
        assert.equal(data[0].test_id, 1);
        assert.equal(data[0].username, "bat");
        assert.equal(data[0].password, "nat");
    });
});

describe('Authentication Suite', function () {
    let a  = 0;
    it('should create a user', function () {
        assert.equal(a,0);
        a = 0;
    });
    it('should not create duplicate users with same username', function () {
        assert.equal(a,0);
        a = 2;
    });
});

describe('Template', function () {
    it('', async function () {
    });
});