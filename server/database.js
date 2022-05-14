const mysql = require('mysql');

const CONNECTION_DETAILS = {
  host     : 'chai-db.c2otfg86lzta.ap-southeast-1.rds.amazonaws.com',
  database : 'my_db',
  user     : 'admin',
  port     : '3306',
  password : 'nofpAz-zytke6-vycbyz',
}

var connection;

// connect to the MySQL server
var connected = false;

function _sqlConnect() {
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
            console.log("SQL:   Connected");
            resolve();
        });
    });
}

// disconnect from the MySQL server
function _sqlDisconnect() {
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
            console.log("SQL:   Disconnected");
            resolve();
        });
    });
}


class Database {
    async query(queryStr) {
        await _sqlConnect();
        console.log(`DATABASE:  querying ${queryStr}`)
        return new Promise(resolve => {
            connection.query(queryStr, function (error, results, fields) {
                if (error) throw error;
                resolve(results);
            });
        });
    }

    // make sure these tables exist
    async assertTable(tableName, properties) {
        let queryStr = `CREATE TABLE IF NOT EXISTS ${tableName} (`;
        properties.forEach((item, index, arr) => {
            queryStr += `${item.name} ${item.type}, `;
        });
        // remove the , at the end
        queryStr = queryStr.substring(0, queryStr.length - 2);

        queryStr += ');';
        await this.query(queryStr);
    }

    // drop table
    async dropTable(tableName) {
        let queryStr = `DROP TABLE ${tableName};`;
        await this.query(queryStr);
    }

    async selectTable(tableName) {
        let queryStr = `SELECT  * FROM ${tableName};`;
        return await this.query(queryStr);
    }

    async insertIntoTable(tableName, entry) {
        let queryStrCol = "";
        let queryStrVal = "";
        for (let name in entry) {
            let value = entry[name];
            queryStrCol += `${name}, `;
            if (typeof value === "string") {
                queryStrVal += `"${value}", `;
            } else {
                queryStrVal += `${value}, `;
            }
        }
        // remove the , at the end
        queryStrCol = queryStrCol.substring(0, queryStrCol.length - 2);
        queryStrVal = queryStrVal.substring(0, queryStrVal.length - 2);

        let queryStr = `INSERT INTO ${tableName} (${queryStrCol}) VALUES (${queryStrVal});`;
        await this.query(queryStr);
    }

    async updateTable(tableName, where, entry) {
        let whereName = Object.keys(where)[0];
        let whereValue = "";
        let value = where[whereName];
        if (typeof value === "string") {
            whereValue = `"${value}"`;
        } else {
            whereValue = `${value}`;
        }
        let queryStrWhere = `${whereName} = ${whereValue}`;

        let queryStrEntries = "";
        for (let name in entry) {
            let entryName = `${name}`
            let entryValue = "";

            let value = entry[name];
            if (typeof value === "string") {
                entryValue = `"${value}"`;
            } else {
                entryValue = `${value}`;
            }
            queryStrEntries += `${entryName} = ${entryValue}, `;
        }
        // remove the , at the end
        queryStrEntries = queryStrEntries.substring(0, queryStrEntries.length - 2);

        let queryStr = `UPDATE ${tableName} SET ${queryStrEntries}  WHERE ${queryStrWhere};`;
        await this.query(queryStr);
    }
}

module.exports.Database = Database;