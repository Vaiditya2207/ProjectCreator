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

const fetchWithRetry = async (url, options, retries = 3, timeout = 5000) => {
    for (let i = 0; i < retries; i++) {
        try {
            const controller = new AbortController();
            const id = setTimeout(() => controller.abort(), timeout);
            const response = await fetch(url, { ...options, signal: controller.signal });
            clearTimeout(id);
            if (!response.ok) throw new Error('Network response was not ok');
            return await response.json();
        } catch (error) {
            if (i === retries - 1) throw error;
        }
    }
}

const getLocation = async (ip) => {
    if (isPrivateIp(ip)) {
        return 'Private Network';
    }
    try {
        const data = await fetchWithRetry(`https://ipapi.co/${ip}/json/`);
        if (data.error) {
            console.log(data);
            return 'Failed to fetch Location';
        }
        return `${data.city || 'Unknown City'}, ${data.region || 'Unknown Region'}, ${data.country_name || 'Unknown Country'}`;
    } catch (error) {
        console.log(error);
        return 'Failed to fetch Location';
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
                userName: result[0].username,
                dateTime: new Date().toLocaleString(),
                location: userLocation,
                device: device
            }];
            const status = await fetch(url, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify(body)
            });
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