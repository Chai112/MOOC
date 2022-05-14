const Db = require('../database');

var assert = require('assert');

describe('Basic', function () {
    it('should connect to the SQL server', async function () {
        Db.sqlConnect();
    });
    it('should pass integration testing', async function () {
        var testingTable = new Db.DatabaseTable("Tests",
            [
                {
                "name": "username",
                "type": "varchar(50)"
                },
                {
                "name": "password",
                "type": "varchar(32)"
                }
        ]);
        testingTable.init();
        await testingTable.dropTable();
        testingTable = new Db.DatabaseTable("Tests",
            [
                {
                "name": "username",
                "type": "varchar(50)"
                },
                {
                "name": "password",
                "type": "varchar(32)"
                }
        ]);
        testingTable.init();
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
        await testingTable.deleteFromTable(
            {password: "mat"},
        );
        let data = await testingTable.selectTable();
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
        data = await testingTable.selectTable();

        assert.equal(data.length, 1);
        assert.equal(data[0].username, "bat");
        assert.equal(data[0].password, "nat");
    });
});

describe('Template', function () {
    it('', async function () {
    });
});