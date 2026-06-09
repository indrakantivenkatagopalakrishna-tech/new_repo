const serverlessExpress = require('@vendia/serverless-express');
const app = require('./app');

// Lambda Handler
exports.handler = serverlessExpress({ app });
