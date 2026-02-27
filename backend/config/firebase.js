const admin = require('firebase-admin');

let serviceAccount;

try {
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        // Load from environment variable (best for Render/Heroku)
        serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
        console.log('Firebase: Loading credentials from environment variable.');
    } else {
        // Load from local file
        serviceAccount = require('./firebase-service-account.json');
        console.log('Firebase: Loading credentials from local JSON file.');
    }

    if (!admin.apps.length) {
        admin.initializeApp({
            credential: admin.credential.cert(serviceAccount)
        });
        console.log('Firebase Admin SDK Initialized for project:', serviceAccount.project_id);
    }
} catch (error) {
    console.error('Firebase Admin Initialization Error:', error.message);
    if (error.code === 'MODULE_NOT_FOUND') {
        console.warn('WARNING: firebase-service-account.json not found. Ensure FIREBASE_SERVICE_ACCOUNT environment variable is set on production.');
    }
}

module.exports = admin;
