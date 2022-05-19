const Db = require('./database');
const sha256 = require('sha256');
const Token = require('./token');

var users = new Db.DatabaseTable("Users",
    "userId",
    [
        {
        name: "username",
        type: "varchar(50)"
        },
        {
        name: "password",
        type: "varchar(64)"
        },
        {
        name: "email",
        type: "varchar(50)"
        },
        {
        name: "token",
        type: "varchar(16)"
        },
        {
        name: "firstName",
        type: "varchar(50)"
        },
        {
        name: "lastName",
        type: "varchar(50)"
        },
        {
        name: "dateCreated",
        type: "datetime"
        },
        {
        name: "dateLastLogin",
        type: "datetime"
        },
]);
users.init();

/*
async function DO_NOT_RUN_FULL_RESET() {
    await users.drop();
    await users.init();
}
module.exports.DO_NOT_RUN_FULL_RESET = DO_NOT_RUN_FULL_RESET;
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
        username: username,
        password: passwordHash,
        email: email,
        token: "",
        firstName: firstName,
        lastName: lastName,
        dateCreated: Db.getDatetime(),
        dateLastLogin: Db.getDatetime(),
    });

    return await loginUser(username, password);
}
module.exports.registerUser = registerUser;

async function loginUser(username, password) {
    // check password
    let data = await users.select({username: username});
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
        {username: username},
        {
            token: token,
            dateLastLogin: Db.getDatetime(),
        },
    );
    return token;
}
module.exports.loginUser = loginUser;


async function logoutUser(token) {
    await users.update(
        {token: token},
        {
            token: ""
        },
    );
}
module.exports.logoutUser = logoutUser;

async function deleteUser(token, password) {
    // hash password
    let passwordHash = sha256(password);

    await users.deleteFrom(
        {token: token, password: passwordHash},
    );
}
module.exports.deleteUser = deleteUser;

async function getUserFromUsername(username) {
    return await users.select({username: username});
}
module.exports.getUserFromUsername = getUserFromUsername;

async function getUserFromToken(token) {
    return await users.select({token: token});
}
module.exports.getUserFromToken = getUserFromToken;

async function getUserFromUserId(userId) {
    return await users.select({userId: userId});
}
module.exports.getUserFromUserId = getUserFromUserId;