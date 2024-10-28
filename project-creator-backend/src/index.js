import express from 'express';
import dotenv from 'dotenv';
import multer from 'multer';
import createTemplate from '../src/routes/createTemplate.js';
import getAllTemplates from './routes/getAllTemplates.js';
import getTemplateById from './routes/getTemplateById.js';
import increaseProjectCount from './routes/increaseProjectCount.js';
import auth from './routes/auth.js';
import cors from 'cors';


dotenv.config();
const port = process.env.SERVER_PORT || 3000;
const app = express();


app.use(express.json());
app.use(cors());

// Configure multer for file uploads
const upload = multer({ dest: 'uploads/' }); // Temporary upload folder

// Set up the route for creating a template
app.post('/api/create-template', upload.single('file'), createTemplate);
app.get('/api/get-all-templates', getAllTemplates);
app.get('/api/get-template-by-id/:id', getTemplateById);
app.get('/api/increase-project-count/:id', increaseProjectCount);
app.post('/api/auth/:type', auth);

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
