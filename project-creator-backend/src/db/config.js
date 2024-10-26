import mysql2 from 'mysql2/promise';
import dotenv from 'dotenv';

dotenv.config();

const pool = mysql2.createPool({
  uri: process.env.DATABASE_URI,
  ssl: {
    rejectUnauthorized: true
  }
});


export default pool;