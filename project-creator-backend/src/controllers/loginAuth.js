import pool from '../db/config.js'; 
import bcrypt from 'bcrypt';

const isMail = (str) => {
    return str.includes('@');
}

const loginAuth = async (identity, password) => {
    const connection = await pool.getConnection();
    try {
        const identityIsMail = isMail(identity);  
        const [result] = await connection.query(`SELECT * FROM users WHERE ${identityIsMail ? 'email' : 'username'} = ?`, [identity]);
        if(result.length == 0) {
            return {
                status: 404,
                message: "User not found"
            }
        }
        const status = await bcrypt.compare(password, result[0].password);
        if(status) {
            return {
                status: 200,
                message: "Login successful"
            }
        } else {
            return {
                status: 401,
                message: "Invalid password"
            }
        }
    } catch (error) {
        console.log(error);
        return {
            status: 500,
            message: "Internal Server Error"
        }
    } finally {
        connection.release();
    }
}

export default loginAuth;