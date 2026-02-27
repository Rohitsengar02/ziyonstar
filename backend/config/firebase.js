const admin = require('firebase-admin');
const path = require('path');

const serviceAccount = require('./firebase-service-account.json');

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

console.log('Firebase Admin SDK Initialized for project:', serviceAccount.project_id);

module.exports = admin;
