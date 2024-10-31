import bcrypt from 'bcrypt';
import pool from '../db/config.js';

const changePassword = async (req, res) => {
    if (!req.body.email || !req.body.password) {
        return res.status(400).json({
            error: 'Bad Request',
            message: 'Email and password are required'
        });
    }
    const connection = await pool.getConnection();
    req.body.password = await bcrypt.hash(req.body.password, 10);
    try {
        const [rows] = await connection.query('SELECT * FROM users WHERE email = ?', [req.body.email]);
        if (rows.length === 0) {
            return res.status(404).json({
                error: 'Not Found',
                message: 'User not found'
            });
        }
        await connection.query('UPDATE users SET password = ? WHERE email = ?', [req.body.password, req.body.email]);
        return res.status(200).json({
            message: 'Password updated'
        });
    } catch (error) {
        return res.status(500).json({
            error: 'Internal Server Error',
            message: 'Internal Server Error'
        });
    } finally {
        connection.release();
    }
};

export default changePassword;