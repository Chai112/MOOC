function generateToken () {
    let token = "";
    let possible = "0123456789abcdef";
    for (let i = 0; i < 32; i++)
        token += possible.charAt(Math.floor(Math.random() * possible.length));
    return token;
}
module.exports.generateToken = generateToken;