import fs from 'fs';
import path from 'path';
import express from 'express';
import multer from 'multer';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const versionsDir = path.join(__dirname, '../versions');

// Configure multer to store uploaded files in the versions directory
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, versionsDir);
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname);
    }
});

const upload = multer({ storage });

const uploadLatestVersion = async (req, res) => {
    try {
        // Check if a file was uploaded
        if (!req.file) {
            return res.status(400).send('No file uploaded.');
        }

        // File uploaded successfully
        res.status(200).send('File uploaded successfully.');
    } catch (error) {
        console.error(error);
        res.status(500).send('Error processing the request.');
    }
};

export default uploadLatestVersion;