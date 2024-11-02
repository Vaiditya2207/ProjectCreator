import failTemplate from "../static/invalidVerificationLinkOrVerificationAlreadyCompleted.js";
import template from "../static/verificationSuccessful.js";
import pool from "../db/config.js";

export default async (req, res) => {
    const code = req.query.code;
    if (!code) {
        return res.status(400).send(failTemplate());
    }

    try {
        const connection = await pool.getConnection();
        const [getUser] = await connection.query('SELECT * FROM userVerificationJunction WHERE verificationCode = ?', [code]);
        if (getUser.length === 0) {
            return res.status(400).send(failTemplate());
        }
        const userId = getUser[0].userId;
        const [checkUser] = await connection.query('SELECT * FROM users WHERE id = ?', [userId]);
        if (checkUser.length === 0 || checkUser[0].isVerified) {
            return res.status(400).send(failTemplate());
        }
        await connection.query('UPDATE users SET isVerified = ? WHERE id = ?', [1, userId]);
        return res.status(200).send(template());
    } catch (error) {
        console.log(error);
        return res.status(500).send(failTemplate());
    }
}