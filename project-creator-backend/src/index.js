import express from 'express';
import dotenv from 'dotenv';
import multer from 'multer';
import createTemplate from '../src/routes/createTemplate.js';
import getAllTemplates from './routes/getAllTemplates.js';
import getTemplateById from './routes/getTemplateById.js';
import increaseProjectCount from './routes/increaseProjectCount.js';
import downloadLatestVersion from './routes/downloadLatestVersion.js';
import { uploadLatestVersion, uploadABC } from './routes/uploadLatestVersion.js';
import auth from './routes/auth.js';
import makeUserAdmin from './routes/makeUserAdmin.js';
import removeAdminAccess from './routes/removeAdminAccess.js';
import updateSwiftVersions from './controllers/updateSwiftVersions.js';
import cors from 'cors';
import downloadArchives from './routes/downloadArchives.js';
import downloadSpecificVersion from './routes/downloadSpecificVersion.js';
import template from './static/forgottenYourPassword.js';
import checkUser from './routes/checkUser.js';
import changePassword from './routes/changePassword.js';
import sendVerificationMail from './routes/sendVerificationMail.js';

dotenv.config();
const port = process.env.SERVER_PORT || 3000;
const app = express();

app.use(express.json());
app.use(cors());

const checkAuth = (req, res, next) => {
    if (!req.headers.authorization) {
        return res.status(401).send('Unauthorized');
    }
    if (req.headers.authorization !== process.env.AUTH_KEY) { 
        return res.status(401).send('Unauthorized');
    }
    next();
}

// Configure multer for file uploads
const upload = multer({ dest: 'uploads/' }); // Temporary upload folder

// Set up the route for creating a template
app.post('/api/create-template', upload.single('file'), createTemplate);
app.get('/api/get-all-templates', getAllTemplates);
app.get('/api/get-template-by-id/:id', getTemplateById);
app.get('/api/increase-project-count/:id', increaseProjectCount);
app.post('/api/auth/:type', auth);
app.get('/api/download/latest', downloadLatestVersion);
app.post('/api/upload', checkAuth, uploadABC.single('file'), uploadLatestVersion);
app.get('/api/download/archives', downloadArchives);
app.get('/api/download-version/:filename', downloadSpecificVersion);
app.get('/api/modify-access/admin/:userId', makeUserAdmin);
app.get('/api/modify-access/remove-admin/:userId', removeAdminAccess);
app.post('/api/afterOtp/change-password', changePassword);
app.post('/api/refresh-swift-versions', async (req, res) => {
    const status = await updateSwiftVersions()
    if (status) {
        return res.status(200).json({
            message: "Updated Versions SuccessFully"
        })
    }
    else {
        return res.status(500).json({
            error: "Internal Server Error",
            message: "Internal Server Error"
        })
    }
});
app.get('/reset-your-password', (req, res) => {
    res.status(200).send(template()) 
});
app.post('/api/check-user', checkUser);
app.post('/api/send-verification-mail', sendVerificationMail);
// app.get('/api/verify-account', verifyAUser);

app.listen(port, async () => {
    console.log("Checking For newer versions");
    const status = await updateSwiftVersions();
    if (status) {
        console.log("Updated Versions SuccessFully")
    }
    else {
        console.log("Internal Server Error")
    }
    console.log(`Server running on port ${port}`);
});