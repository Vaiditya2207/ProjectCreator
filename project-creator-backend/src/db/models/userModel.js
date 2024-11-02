import pool from "../config.js";

const model = async () => {
    const query = `CREATE TABLE IF NOT EXISTS users 
    (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL,
        password VARCHAR(255) NOT NULL,
        isVerified BOOLEAN DEFAULT FALSE,
        admin BOOLEAN DEFAULT FALSE
    )`

    try {
        const connection = await pool.getConnection();
        await connection.query(query);
        connection.release();
    } catch (error) {
        console.log(error);
    }
}

export default model;