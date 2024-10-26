import pool from "../db/config.js"

const increaseProjectCount = async (req, res) => {
    const projectId = req.params.id
    const connection = await pool.getConnection()
    try {
        if(!parseInt(projectId)) {
            return res.status(400).json({
                message: "Invalid project ID",
                error: "Invalid project ID"
            })
        }

        const [result] = await connection.query(`SELECT * FROM templateLibrary WHERE id = ${projectId}`)

        if(result.length == 0) {
            return res.status(404).json({
                message: "Project not found",
                error: "Project not found"
            })
        }

        await connection.query(`UPDATE templateLibrary SET currentProjects = currentProjects + 1 WHERE id = ${projectId}`)

        res.status(200).json({
            message: "Project count increased successfully"
        })
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

export default increaseProjectCount;