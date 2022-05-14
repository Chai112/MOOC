const Db = require('./database');

async function test() {
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
    console.log(data);
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
    console.log(data);

    if (data.length === 1 &&
        data[0].username === "bat" &&
        data[0].password === "nat"
    ) {
        console.log("TEST: PASSED   database looks good");
    } else {
        console.log("TEST: FAILED   database not looking good");
    }
}

module.exports.test = test;