import getVerificationCode from '../controllers/sendVerificationMail.js';
import pool from '../db/config.js';


export default async (req, res) => {
    const email = req.body.email;
    if (!email) {
        return res.status(400).json({ message: 'Email is required' });
    }
    const connection = await pool.getConnection();
    try {
        const vericationCode = await getVerificationCode(email);
        if (vericationCode == false) {
            return res.status(400).json({ message: 'User not found' });
        }
        const headers = {
            'Content-Type': 'application/json',
            Authorization: process.env.MAIL_SERVICE_AUTH_KEY,
        }
        const body = [{
            to: email,
            subject: 'Verify Your Account - ProjectCreator',
            body: "Click this link to verify your account:",
            username: "user",
            verificationLink: 'https://projectcreator.onrender.com/verify-account?code=' + vericationCode
        }]
        const status = await fetch(process.env.MAIL_SERVICE_URL + '/api/projectcreator/verification-mail', {
            method: 'POST',
            headers,
            body: JSON.stringify(body)
        })
        console.log(status);
        if (status.status !== 200) {
            return res.status(500).json({ message: 'Internal server error' });
        }
        return res.status(200).json({ message: 'Verification mail sent successfully' });

    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: 'Internal server error' });
    } finally {
        connection.release();
    }
};