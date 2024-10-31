import pool from '../db/config.js';

const checkUser = async (req, res) => {
    if (!req.body.email) {
        return res.status(400).json({
            error: 'Bad Request',
            message: 'Email is required'
        });
    }
    const connection = await pool.getConnection();
    try {
        const [rows] = await connection.query('SELECT * FROM users WHERE email = ?', [req.body.email]);
        if (rows.length === 0) {
            return res.status(404).json({
                error: 'Not Found',
                message: 'User not found'
            });
        }
        return res.status(200).json({
            message: 'User found',
            user: rows[0]
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

export default checkUser;