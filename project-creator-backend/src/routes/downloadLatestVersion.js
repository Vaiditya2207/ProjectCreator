import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import express from 'express';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const versionsDir = path.join(__dirname, '../versions');

const downloadLatestVersion = async (req, res) => {
    try {
        // Read the versions directory
        const files = fs.readdirSync(versionsDir);

        // Filter out the .dmg files
        const dmgFiles = files.filter(file => file.endsWith('.dmg'));

        // Sort the .dmg files to find the latest one
        const latestDmg = dmgFiles.sort((a, b) => {
            const versionA = a.replace('version', '').replace('.dmg', '').split('.').map(Number);
            const versionB = b.replace('version', '').replace('.dmg', '').split('.').map(Number);
            for (let i = 0; i < versionA.length; i++) {
                if (versionA[i] > versionB[i]) return -1;
                if (versionA[i] < versionB[i]) return 1;
            }
            return 0;
        })[0];

        // Construct the path to the latest .dmg file
        const dmgPath = path.join(versionsDir, latestDmg);

        // Check if the file exists
        if (fs.existsSync(dmgPath)) {
            // Send the file as a response
            res.download(dmgPath, latestDmg, (err) => {
                if (err) {
                    console.error(err);
                    res.status(500).send('Error downloading the file.');
                }
            });
        } else {
            res.status(404).send('File not found.');
        }
    } catch (error) {
        console.error(error);
        res.status(500).send('Error processing the request.');
    }
};

const app = express();
app.get('/download-latest', downloadLatestVersion);

app.listen(8000, () => {
    console.log('Server running on port 8000');
});

export default downloadLatestVersion;