import fs from 'fs';
import path from 'path';
import multer from 'multer';
import axios from 'axios';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const versionsDir = path.join(__dirname, '../versions');

// Ensure the versions directory exists
if (!fs.existsSync(versionsDir)) {
    fs.mkdirSync(versionsDir, { recursive: true });
}

// Configure multer to store uploaded files in the versions directory
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, versionsDir);
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname);
    }
});

const uploadABC = multer({ storage });

const uploadLatestVersion = async (req, res) => {
    try {
        // Check if a file was uploaded
        if (!req.file) {
            return res.status(400).send('No file uploaded.');
        }

        // File uploaded successfully
        res.status(200).send('File uploaded successfully.');

        // Push the file to GitHub repository
        const filePath = path.join(versionsDir, req.file.originalname);
        await pushToGitHub(filePath, req.file.originalname);
    } catch (error) {
        console.error(error);
        res.status(500).send('Error processing the request.');
    }
};

const pushToGitHub = async (filePath, fileName) => {
    const repo = 'TemplateLibraryByCodemelon/swift-application-versions';
    const branch = 'main';
    const commitMessage = 'Add new dmg file';
    const username = 'Vaiditya2207';
    const token = process.env.GITHUB_KEY;

    const fileContent = fs.readFileSync(filePath, { encoding: 'base64' });

    const url = `https://api.github.com/repos/${repo}/contents/${fileName}`;

    const data = {
        message: commitMessage,
        content: fileContent,
        branch: branch
    };

    const config = {
        headers: {
            'Authorization': `token ${token}`,
            'Accept': 'application/vnd.github.v3+json'
        }
    };

    try {
        const response = await axios.put(url, data, config);
        console.log(`Push to GitHub successful: ${response.data.commit.sha}`);
    } catch (error) {
        console.error(`Error pushing to GitHub: ${error.message}`);
    }
};

export { uploadLatestVersion, uploadABC };