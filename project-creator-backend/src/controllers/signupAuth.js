import pool from '../db/config.js';
import bcrypt from 'bcrypt'

const validateEmail = (email) => {
    const re = /\S+@\S+\.\S+/;
    return re.test(email);
}

const signupAuth = async (username, email, password) => {
    const connection = await pool.getConnection();
    password = await bcrypt.hash(password, 10);
    try {
        if (!username || !email || !password) {
            return { status: 400, message: 'All fields are required' };
        }

        if (validateEmail(email) === false) {
            return { status: 400, message: 'Invalid email' };
        }

        const [isAlreadyUser] = await connection.query('SELECT * FROM users WHERE email = ?', [email]);
        if (isAlreadyUser.length > 0) {
            return { status: 409, message: 'User already exists' };
        }

        const [isUsernameAvailable] = await connection.query('SELECT * FROM users WHERE username = ?', [username]);
        if(isUsernameAvailable.length > 0) {
            return { status: 409, message: 'Username already taken' };
        }

        const [result] = await connection.query('INSERT INTO users (username, email, password) VALUES (?, ?, ?)', [username, email, password]);
        return { status: 201, message: 'User created successfully' };
    } catch (err) {
        console.error(err);
        return { status: 500, message: 'Internal Server Error' };
    } finally {
        connection.release();
    }
}

export default signupAuth;