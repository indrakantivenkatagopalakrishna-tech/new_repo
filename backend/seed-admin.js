/**
 * seed-admin.js — Creates the first admin user in the database.
 *
 * Usage:
 *   node seed-admin.js
 *
 * Set credentials via environment variables or edit the defaults below:
 *   ADMIN_EMAIL=your@email.com ADMIN_PASSWORD=YourSecurePass123! node seed-admin.js
 */

require('dotenv').config();
const { Pool } = require('pg');
const bcrypt = require('bcryptjs');
const readline = require('readline');

const DATABASE_URL = process.env.DATABASE_URL;
if (!DATABASE_URL) {
  console.error('ERROR: DATABASE_URL environment variable is not set.');
  console.error('Add it to your .env file or set it before running this script.');
  process.exit(1);
}

const pool = new Pool({
  connectionString: DATABASE_URL,
  ssl: DATABASE_URL.includes('neon.tech') ? { rejectUnauthorized: false } : false,
});

async function promptInput(prompt, isPassword = false) {
  const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
  return new Promise((resolve) => {
    if (isPassword) process.stdout.write(prompt);
    rl.question(isPassword ? '' : prompt, (answer) => {
      rl.close();
      if (isPassword) process.stdout.write('\n');
      resolve(answer.trim());
    });
  });
}

async function main() {
  let email = process.env.ADMIN_EMAIL;
  let password = process.env.ADMIN_PASSWORD;

  if (!email) {
    email = await promptInput('Admin Email: ');
  }
  if (!password) {
    password = await promptInput('Admin Password: ', true);
  }

  if (!email || !password) {
    console.error('Email and password are required.');
    process.exit(1);
  }

  if (password.length < 8) {
    console.error('Password must be at least 8 characters.');
    process.exit(1);
  }

  console.log('\nConnecting to database...');

  try {
    // Ensure admin_users table has email column (migration-safe)
    await pool.query(`
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM information_schema.columns
          WHERE table_name = 'admin_users' AND column_name = 'email'
        ) THEN
          ALTER TABLE admin_users ADD COLUMN email VARCHAR(255) UNIQUE;
        END IF;
      END
      $$;
    `);

    const passwordHash = await bcrypt.hash(password, 12);

    // Upsert admin user
    const result = await pool.query(
      `INSERT INTO admin_users (username, email, password_hash, role)
       VALUES ($1, $2, $3, 'admin')
       ON CONFLICT (username) DO UPDATE
         SET email = EXCLUDED.email,
             password_hash = EXCLUDED.password_hash,
             updated_at = NOW()
       RETURNING id, username, email, role`,
      [email, email, passwordHash]
    );

    const admin = result.rows[0];
    console.log('\n✅ Admin user created/updated successfully!');
    console.log(`   ID:    ${admin.id}`);
    console.log(`   Email: ${admin.email}`);
    console.log(`   Role:  ${admin.role}`);
    console.log('\nYou can now log in at: https://indrakantivenkatagopalakrishna.com/admin/index.html');
  } catch (err) {
    console.error('\nDatabase error:', err.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

main();
