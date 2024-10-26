import pool from '../db/config.js';
import loginAuth from '../controllers/loginAuth.js';

const auth = async (req, res) => {
    const connection = await pool.getConnection();
    const type = req.params.type;
    try {
        if (type == "login") {
            const status = await loginAuth(req.body.identity, req.body.password);
            if (status.status == 200) {
                res.status(200).json({
                    message: status.message
                });
            } else if (status.status == 401) {
                res.status(401).json({
                    message: status.message
                });
            } else if (status.status == 404) {
                res.status(404).json({
                    message: status.message
                });
            } else {
                res.status(500).json({
                    message: status.message
                });
            }
        } else if (type == "signup"){
            
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({
            message: "Internal Server Error",
            error: err
        });
    }
    finally {
        connection.release();
    }
}

export default auth;