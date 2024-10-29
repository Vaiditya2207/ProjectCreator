import pool from '../db/config.js';
import loginAuth from '../controllers/loginAuth.js';
import signupAuth from '../controllers/signupAuth.js';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
dotenv.config();

const auth = async (req, res) => {
    const connection = await pool.getConnection();
    const type = req.params.type;
    try {
        if (type == "login") {
            const status = await loginAuth(req.body.identity, req.body.password);
            if (status.status == 200) {
                res.status(200).json({
                    token: jwt.sign(status.payload, process.env.JWT_SECRET),
                    isAdmin: status.payload.admin ? true : false,  
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
            const status = await signupAuth(req.body.username, req.body.email, req.body.password);
            if (status.status == 201) {
                res.status(201).json({
                    token: jwt.sign({ username: req.body.username, email: req.body.email, admin: false }, process.env.JWT_SECRET),
                    isAdmin: false,
                    message: status.message
                });
            } else if (status.status == 400) {
                res.status(400).json({
                    message: status.message
                });
            } else if (status.status == 409) {
                res.status(409).json({
                    message: status.message
                });
            } else {
                res.status(500).json({
                    message: status.message
                });

            }
        } else {
            res.status(400).json({
                message: "Invalid type"
            });
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