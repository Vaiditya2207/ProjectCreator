import dotenv from 'dotenv';
import pool from '../db/config.js';
dotenv.config();

const makeUserAdmin = async (req, res) => {
    const userId = req.params.userId;
    if (isNaN(parseInt(userId))) {
        return res.status(400).json({
            message: "UserId is not provided",
            error: "Wrong Type of userId"
        });
    }
    const connection = await pool.getConnection();
    try {
        const authKey = req.headers.authorization;
        if (!authKey) {
            return res.status(401).json({
                message: "Unauthorized",
                error: "No auth key provided"
            });
        }
        if (authKey !== process.env.AUTH_KEY) {
            return res.status(401).json({
                message: "Unauthorized",
                error: "Invalid auth key"
            });
        }

        const [findUser] = await connection.query("SELECT * FROM users WHERE id = ?", [userId]);
        if (findUser.length === 0) {
            return res.status(404).json({
                message: "User not found",
                error: "User not found"
            });
        }

        await connection.query("UPDATE users SET admin = TRUE WHERE id = ?", [userId]);
        res.status(200).json({
            message: "User is now an admin",
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({
            message: "Internal Server Error",
            error: err
        });
    } finally {
        connection.release();
    }
};

export default makeUserAdmin;