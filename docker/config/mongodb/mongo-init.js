db = db.getSiblingDB('arl');

var initUser = _getEnv('ARL_USER') || 'admin'
var initPass = _getEnv('ARL_PASS') || 'arlpass'

print('Initializing MongoDB with user: ' + initUser);

db.user.drop();

var salt = 'arlsalt!@#';
var hashedPassword = hex_md5(salt + initPass);

db.user.insertOne({
    username: initUser,
    password: hashedPassword
});

print('MongoDB initialization complete: User ' + initUser + ' created.');