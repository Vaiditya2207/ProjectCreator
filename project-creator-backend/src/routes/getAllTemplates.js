import pool from '../db/config.js'

const getAllTemplates = async (req, res) => {
    const connection = await pool.getConnection()
    try {
        const [result] = await connection.query(`SELECT * FROM templateLibrary`)
        res.status(200).json(result)
    } catch (error) {
        res.status(500).json({
            message: "Internal Server Error",
            error: error
        })
    } finally {
        connection.release()
    }   
}

export default getAllTemplates;