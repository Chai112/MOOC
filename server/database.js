const mysql = require('mysql');

const CONNECTION_DETAILS = {
  host     : 'chai-db.c2otfg86lzta.ap-southeast-1.rds.amazonaws.com',
  database : 'my_db',
  user     : 'admin',
  port     : '3306',
  password : 'nofpAz-zytke6-vycbyz',
}

const DEBUG_VERBOSE = false;
const DATETIME = "$$DATETIME$$";

var connection;

// connect to the MySQL server
var connected = false;

function sqlConnect() {
    if (connected)  // if already connected
        return Promise.resolve();
    // handshake
    connection = mysql.createConnection(CONNECTION_DETAILS);
    // then perform connection
    return new Promise(resolve => {
        connection.connect((err) => {
            if (err) {
                console.log(err.message);
                throw err;
            }
            connected = true;
            resolve();
        });
    });
}

// disconnect from the MySQL server
function sqlDisconnect() {
    if (!connected)  // if already disconnected
        return Promise.resolve();

    // terminate connection to server
    return new Promise(resolve => {
        connection.end((err) => {
            if (err) {
                console.log(err.message);
                throw err;
            }
            connected = false;
            resolve();
        });
    });
}

// wraps a string around strings
function sanitizeSqlValue(input) {

    // special for datetimes
    if (input === DATETIME)
        return `CURRENT_TIMESTAMP`;

    if (typeof input === "string") {
        // just to be safe!
        return `"${encodeURI(input)}"`;
    } else if (typeof input === "boolean") {
        if (input) {
            return '1';
        } else {
            return '0';
        }
    } else {
        return `${input}`;
    }
}

function getDatetime() {
    return DATETIME;
}

function readBool(input) {
    let output = input.readInt8();
    if (output === 1) {
        return true;
    } else if (output === 0) {
        return false;
    } else {
        throw "not a bool!";
    }
}

class DatabaseTable {
    tableName;
    tableKeyName;
    properties;

    constructor(tableName, tablePrivateKeyName, properties) {
        this.tableName = tableName;
        this.tableKeyName = tablePrivateKeyName;
        this.properties = properties;
    }

    async getNextKey() {
        let queryStr = `SELECT MAX(${this.tableKeyName}) AS id_max FROM ${this.tableName}`;
        let result = await this.query(queryStr);
        result = result[0]; // get the first result

        // incase if no elements existed previously
        if (result.id_max === null) {
            result.id_max = 0;
        }

        return result.id_max + 1;
    }

    async init() {
        let queryStr = `CREATE TABLE IF NOT EXISTS ${this.tableName} (`;
        // format for table key
        queryStr += `${this.tableKeyName} int, `;

        // format name:type
        this.properties.forEach((item, index, arr) => {
            queryStr += `${item.name} ${item.type}, `;
        });
        // remove the , at the end
        queryStr = queryStr.substring(0, queryStr.length - 2);

        queryStr += ');';
        await this.query(queryStr);
    }

    async query(queryStr) {
        await sqlConnect();
        if (DEBUG_VERBOSE) {
            console.log(`DATABASE:  querying ${queryStr}`)
        }
        return new Promise(resolve => {
            connection.query(queryStr, function (error, results, fields) {
                if (error) throw error;
                resolve(results);
            });
        });
    }

    // drop table
    async drop() {
        let queryStr = `DROP TABLE ${this.tableName};`;
        await this.query(queryStr);
    }

    async select(where) {
        let queryStr = `SELECT * FROM ${this.tableName}`;
        if (where !== undefined) {
            let queryStrWheres = "";
            for (let name in where) {
                let value = where[name];
                queryStrWheres += `${name} = ${sanitizeSqlValue(value)} AND `;
            }
            // remove the AND at the end
            queryStrWheres = queryStrWheres.substring(0, queryStrWheres.length - 5);

            queryStr += ` WHERE ${queryStrWheres}`
        }
        queryStr += ";";
        return await this.query(queryStr);
    }

    async insertInto(entry) {
        let queryStrCol = `${this.tableKeyName}, `;
        let nextKey = await this.getNextKey();
        let queryStrVal = `${nextKey}, `;
        for (let name in entry) {
            let value = entry[name];
            queryStrCol += `${name}, `;
            queryStrVal += `${sanitizeSqlValue(value)}, `
        }
        // remove the , at the end
        queryStrCol = queryStrCol.substring(0, queryStrCol.length - 2);
        queryStrVal = queryStrVal.substring(0, queryStrVal.length - 2);

        let queryStr = `INSERT INTO ${this.tableName} (${queryStrCol}) VALUES (${queryStrVal});`;
        await this.query(queryStr);
        return nextKey;
    }

    async update(where, entry) {
        let queryStrWheres = "";
        for (let name in where) {
            let value = where[name];
            queryStrWheres += `${name} = ${sanitizeSqlValue(value)} AND `;
        }
        // remove the AND at the end
        queryStrWheres = queryStrWheres.substring(0, queryStrWheres.length - 5);

        let queryStrEntries = "";
        for (let name in entry) {
            let value = entry[name];
            queryStrEntries += `${name} = ${sanitizeSqlValue(value)}, `;
        }
        // remove the , at the end
        queryStrEntries = queryStrEntries.substring(0, queryStrEntries.length - 2);

        let queryStr = `UPDATE ${this.tableName} SET ${queryStrEntries} WHERE ${queryStrWheres};`;
        await this.query(queryStr);
    }

    async deleteFrom(where) {
        let queryStrWheres = "";
        for (let name in where) {
            let value = where[name];
            queryStrWheres += `${name} = ${sanitizeSqlValue(value)} AND `;
        }
        // remove the AND at the end
        queryStrWheres = queryStrWheres.substring(0, queryStrWheres.length - 5);
        let queryStr = `DELETE FROM ${this.tableName} WHERE ${queryStrWheres}`;
        await this.query(queryStr);
    }
}

module.exports.sqlConnect = sqlConnect;
module.exports.sqlDisconnect = sqlDisconnect;
module.exports.getDatetime = getDatetime;
module.exports.readBool = readBool;

module.exports.DatabaseTable = DatabaseTable;