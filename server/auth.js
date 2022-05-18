const Db = require('./database');
const sha256 = require('sha256');
const Token = require('./token');

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
        {
        "name": "dateLastLogin",
        "type": "datetime"
        },
]);
users.init();

/*
async function DO_NOT_RUN_FULL_RESET() {
    await users.drop();
    await users.init();
}
DO_NOT_RUN_FULL_RESET();
*/

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
        "dateLastLogin": Db.getDatetime(),
    });

    return await loginUser(username, password);
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
    let token = Token.generateToken();

    await users.update(
        {"username": username},
        {
            "token": token,
            "dateLastLogin": Db.getDatetime(),
        },
    );
    return token;
}

async function logoutUser(token) {
    await users.update(
        {"token": token},
        {
            "token": ""
        },
    );
}

async function deleteUser(token, password) {
    await users.deleteFrom(
        {"token": token, "password": password},
    );
}

async function getUserFromToken(token) {
    return await users.select({"token": token});
}

module.exports.registerUser = registerUser;
module.exports.loginUser = loginUser;
module.exports.logoutUser = logoutUser;
module.exports.deleteUser = deleteUser;

module.exports.getUserFromToken = getUserFromToken;