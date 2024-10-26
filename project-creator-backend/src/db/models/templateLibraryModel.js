import pool from '../config.js'

const model = async () => { 
    const query = `CREATE TABLE IF NOT EXISTS templateLibrary 
    (
        id INT AUTO_INCREMENT PRIMARY KEY,
        templateName VARCHAR(255) NOT NULL,
        templateDescription VARCHAR(255) NOT NULL,
        templateAuthor VARCHAR(255) NOT NULL,
        templateVersion VARCHAR(255) NOT NULL DEFAULT '1.0',
        templateType VARCHAR(255) NOT NULL,
        templateUrl VARCHAR(255) NOT NULL,
        currentProjects INT DEFAULT 0,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
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