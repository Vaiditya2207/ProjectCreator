import pool from '../db/config.js';
import { v4 } from 'uuid';

const getVerificationCode = async (email) => {
    const connection = await pool.getConnection();
    try {
        const [rows] = await connection.query('SELECT * FROM users WHERE email = ?', [email]);
        if (rows.length === 0) {
            return false
        }
        const userId = rows[0].id;

        const [check] = await connection.query('SELECT * FROM userVerificationJunction WHERE userId = ?', [userId]);
        if (check.length > 0) {
            return check[0].verificationCode
        }
        const vericationCode = v4() + v4();
        const status = await connection.query('INSERT INTO userVerificationJunction (userId, verificationCode) VALUES (?, ?)', [userId, vericationCode]);
        if (status[0].affectedRows === 0) {
            return false
        }
        return vericationCode
    } catch (error) {
        console.error(error);
        return false
    } finally { 
        connection.release();
    }
};

export default getVerificationCode;