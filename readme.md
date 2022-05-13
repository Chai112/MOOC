# Massive Open Online Course
developed by Chaidhat Chaimongkol

### Server Installation
This is usually configured for AWS EC2 and AWS RDS for backend.
Ensure that the AWS RDS allows public connections for EC2 outside of the VPC and include all security groups. Make sure that when you are creating it that under additional information, specify a database name.
1. Get node and npm.
```
$ npm install pm2 express mysql cors
```
2. Retype the .PEM file directory in `ssh-server.sh` and `build-server.sh`
3. Reconfigure the ssh/scp address in the same files.
4. Reconfigure SQL connection to a MySQL server in `server/server.js`
5. profit.
Any difficulties contact chaidhatchaimongkol@gmail.com