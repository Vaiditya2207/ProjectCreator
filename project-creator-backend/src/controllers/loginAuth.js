import pool from '../db/config.js'; 
import bcrypt from 'bcrypt';
import dotenv from 'dotenv';
dotenv.config();

const isMail = (str) => {
    return str.includes('@');
}

const isPrivateIp = (ip) => {
    return /^10\./.test(ip) ||
           /^192\.168\./.test(ip) ||
           /^172\.(1[6-9]|2[0-9]|3[0-1])\./.test(ip) ||
           /^::1$/.test(ip) ||
           /^127\./.test(ip);
}

const getLocation = async (ip) => {
    if (isPrivateIp(ip)) {
        return 'Private Network';
    }
    try {
        const response = await fetch(`https://ipapi.co/${ip}/json/`);
        const data = await response.json();
        if (data.error) {
            console.log(error)
            return 'Unknown Location';
        }
        return `${data.city || 'Unknown City'}, ${data.region || 'Unknown Region'}, ${data.country_name || 'Unknown Country'}`;
    } catch (error) {
        console.log(error);
        return 'Unknown Location';
    }
}


const loginAuth = async (identity, password, location, device) => {
    if (!identity || !password) { 
        return {
            status: 400,
            message: "All fields are required"
        }
    }
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
                message: "Login successful",
                payload: {
                    username: result[0].username,
                    email: result[0].email,
                    admin: result[0].admin
                }
            }
        } else {
            const url = process.env.MAIL_SERVICE_URL + "/api/projectcreator/failed-login";
            const headers = {
                'Content-Type': 'application/json',
                'Authorization': process.env.MAIL_SERVICE_AUTH_KEY
            }
            const userLocation = await getLocation(location);
            const body = [{
                to: result[0].email,
                subject: "Suspicious Login Attempt",
                body: "Please take necessary action as soon as possible",
                username: result[0].username,
                dateTime: new Date().toLocaleString(),
                location: userLocation,
                device: device
            }];
            const status = await fetch(url, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify(body)
            });
            console.log(status);
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