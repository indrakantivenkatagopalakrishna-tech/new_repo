const { Pool } = require('pg');
require('dotenv').config();

const connectionString = process.env.DATABASE_URL;

if (!connectionString) {
  console.warn("WARNING: DATABASE_URL environment variable is not set. Database connections will fail.");
}

const pool = new Pool({
  connectionString: connectionString,
  ssl: connectionString && (connectionString.includes('neon.tech') || process.env.DB_SSL === 'true')
    ? { rejectUnauthorized: false }
    : false,
  max: 10, // Max clients in pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool: pool
};
