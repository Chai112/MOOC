const Db = require('./database');
const sha256 = require('sha256');

var users = new Db.DatabaseTable("Users",
    "userId",
    [
        {
        "name": "username",
        "type": "varchar(50)"
        },
        {
        "name": "password",
        "type": "varchar(64)"
        },
        {
        "name": "email",
        "type": "varchar(50)"
        },
        {
        "name": "token",
        "type": "varchar(32)"
        },
        {
        "name": "firstName",
        "type": "varchar(50)"
        },
        {
        "name": "lastName",
        "type": "varchar(50)"
        },
        {
        "name": "dateCreated",
        "type": "datetime"
        },
]);
users.init();

async function registerUser(username, password, email, firstName, lastName) {
    // test if a user already exists with that username
    let data = await users.select({"username": username});
    if (data.length > 0) {
        throw "user already exists";
    }

    // hash password
    let passwordHash = sha256(password);
    
    // insert new user
    await users.insertInto({
        "username": username,
        "password": passwordHash,
        "email": email,
        "token": "",
        "firstName": firstName,
        "lastName": lastName,
        "dateCreated": Db.getDatetime(),
    });

    return await loginUser(username, password);
}

async function testGetAllUsers() {
    await users.drop();
    await users.init();

    return await users.select();
}

async function loginUser(username, password) {
    // check password
    let data = await users.select({"username": username});
    if (data.length < 0) {
        throw "no user exists";
    }

    data = data[0];

    // hash password
    let passwordHash = sha256(password);

    if (data.password !== passwordHash) {
        throw "passwords do not match";
    }

    // create token
    let token = "";
    let possible = "0123456789abcdef";
    for (let i = 0; i < 32; i++)
        token += possible.charAt(Math.floor(Math.random() * possible.length));

    await users.update(
        {"username": username},
        {
            "token": token
        },
    );
    return token;
}

async function getUserFromToken(token) {
    return await users.select({"token": token});
}

module.exports.registerUser = registerUser;
module.exports.loginUser = loginUser;
module.exports.getUserFromToken = getUserFromToken;
module.exports.testGetAllUsers = testGetAllUsers;