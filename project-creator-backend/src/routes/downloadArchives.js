import fs from 'fs';
import path from 'path';
import express from 'express';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const versionsDir = path.join(__dirname, '../versions');

const downloadArchives = async (req, res) => {
    try {
        // Read the versions directory
        const files = fs.readdirSync(versionsDir).filter(file => file.endsWith('.dmg'));

        // Generate HTML content
        let htmlContent = '<html><body><h1>Available Versions</h1><ul>';
        files.forEach(file => {
            htmlContent += `<li><a href="/api/download-version/${file}">${file}</a></li>`;
        });
        htmlContent += '</ul></body></html>';

        // Send the HTML file as a response
        res.send(htmlContent);
    } catch (error) {
        console.error(error);
        res.status(500).send('Error processing the request.');
    }
};

export default downloadArchives;