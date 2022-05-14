# Massive Open Online Course
developed by Chaidhat Chaimongkol

### Server Installation
This is usually configured for AWS EC2 Linux and AWS RDS for backend.
Ensure that you go into security groups and edit inbound rules so that any ipv4 can be sent to it (add a new rule). Make sure that when you are creating it that under additional information, specify a database name.
1. Get node and npm.
2. Install dependencies
```
$ npm install pm2 express mysql cors
```
3. Retype the .PEM file directory in `ssh-server.sh` and `build-server.sh`
4. Reconfigure the ssh/scp address in the same files.
5. Reconfigure SQL connection to a MySQL server in `server/server.js`
6. Profit.

Any difficulties contact chaidhatchaimongkol@gmail.com