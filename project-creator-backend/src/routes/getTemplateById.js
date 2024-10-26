import pool from '../db/config.js'

const getTemplateById = async (req, res) => {
    const templateId = req.params.id
    const connection = await pool.getConnection()
    try {
        if(!parseInt(templateId)) {
            return res.status(400).json({
                message: "Invalid template ID",
                error: "Invalid template ID"
            })
        }

        const [result] = await connection.query(`SELECT * FROM templateLibrary WHERE id = ${templateId}`)

        if(result.length == 0) {
            return res.status(404).json({
                message: "Template not found",
                error: "Template not found"
            })
        }

        res.status(200).json(result[0])
    } catch (err) {
        console.log(err)
        res.status(500).json({
            message: "Internal Server Error",
            error: err
        })
    } finally {
        connection.release()
    }
}

export default getTemplateById;