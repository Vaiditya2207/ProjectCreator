import fs from 'fs';
import path from 'path';
import express from 'express';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const versionsDir = path.join(__dirname, '../versions');

const downloadSpecificVersion = async (req, res) => {
    const { filename } = req.params;
    const filePath = path.join(versionsDir, filename);

    if (fs.existsSync(filePath)) {
        res.download(filePath, filename, (err) => {
            if (err) {
                console.error(err);
                res.status(500).send('Error downloading the file.');
            }
        });
    } else {
        res.status(404).send('File not found.');
    }
}

export default downloadSpecificVersion;