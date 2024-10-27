import multer from 'multer';
import AdmZip from 'adm-zip';
import { Octokit } from 'octokit';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import simpleGit from 'simple-git';
import pool from '../db/config.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config();
const upload = multer({ dest: 'uploads/' });

const octokit = new Octokit({
  auth: process.env.GITHUB_KEY,
});

const deleteDirectory = (dirPath) => {
  if (fs.existsSync(dirPath)) {
    fs.readdirSync(dirPath).forEach((file) => {
      const curPath = path.join(dirPath, file);
      fs.lstatSync(curPath).isDirectory() ? deleteDirectory(curPath) : fs.unlinkSync(curPath);
    });
    fs.rmdirSync(dirPath);
  }
};

const createTemplate = async (req, res) => {
  const connection = await pool.getConnection();
  const tempExtractPath = path.join(__dirname, 'extracted_temp');
  const finalExtractPath = path.join(__dirname, 'extracted', `${req.body.templateName}by${req.body.templateAuthor}`);
  try {
    const { templateName, templateDescription, templateAuthor, templateType } = req.body;
    const existingTemplateQuery = `SELECT * FROM templateLibrary WHERE templateName = ? AND templateAuthor = ?`;
    const [result] = await connection.query(existingTemplateQuery, [templateName, templateAuthor]);

    if (!req.file || !templateName || !templateDescription || !templateAuthor || !templateType) {
      return res.status(400).json({ message: "All fields are required", error: "All fields are required" });
    }
    if (result.length > 0) {
      return res.status(400).json({ message: "Template with the same name by this author already exists", error: "Duplicate template" });
    }

    const uploadedFilePath = req.file.path;

    if (!fs.existsSync(finalExtractPath)) fs.mkdirSync(finalExtractPath, { recursive: true });
    if (!fs.existsSync(tempExtractPath)) fs.mkdirSync(tempExtractPath);

    const zip = new AdmZip(uploadedFilePath);
    zip.extractAllTo(tempExtractPath, true);

    const macOSXFolder = path.join(tempExtractPath, '__MACOSX');
    if (fs.existsSync(macOSXFolder)) deleteDirectory(macOSXFolder);

    const extractedContents = fs.readdirSync(tempExtractPath).find(file => fs.statSync(path.join(tempExtractPath, file)).isDirectory());
    if (extractedContents) {
      const contentPath = path.join(tempExtractPath, extractedContents);
      fs.readdirSync(contentPath).forEach(file => {
        const sourcePath = path.join(contentPath, file);
        const destinationPath = path.join(finalExtractPath, file);
        if (file !== '.git') {
          fs.renameSync(sourcePath, destinationPath);
        }
      });
    }

    const repoName = `${templateName}by${templateAuthor}`;
    let repoResponse;
    try {
      repoResponse = await octokit.rest.repos.createInOrg({
        org: 'TemplateLibraryByCodemelon',
        name: repoName,
        private: false,
      });
    } catch (repoError) {
      if (repoError.status === 422) {
        return res.status(400).json({ message: 'Repository with the same name already exists in the organization' });
      } else {
        throw repoError;
      }
    }

    const token = process.env.GITHUB_KEY;
    if (!token) {
      return res.status(500).json({ message: 'GitHub token is not defined in environment variables' });
    }

    const repoUrl = `https://${token}@github.com/TemplateLibraryByCodemelon/${repoName}.git`;
    const git = simpleGit(finalExtractPath);

    await git.init();
    const remotes = await git.getRemotes();
    if (remotes.some(remote => remote.name === 'origin')) {
      await git.removeRemote('origin');
    }
    await git.addRemote('origin', repoUrl);
    await git.add('.');
    await git.commit('Initial commit');

    try {
      await git.push('origin', 'main', ['--force']);
    } catch (pushError) {
      console.error('Push failed:', pushError);
      return res.status(500).json({ message: 'Error pushing to GitHub', error: pushError.message });
    }

    await connection.query(
      "INSERT INTO templateLibrary (templateName, templateDescription, templateAuthor, templateType, templateUrl) VALUES (?, ?, ?, ?, ?)",
      [templateName, templateDescription, templateAuthor, templateType, repoResponse.data.html_url]
    );

    res.status(201).json({ message: 'Template created successfully!', repoUrl: repoResponse.data.html_url });

  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error creating template', error: error.message });
  } finally {
    if (req.file?.path && fs.existsSync(req.file.path)) fs.unlinkSync(req.file.path);
    if (fs.existsSync(tempExtractPath)) deleteDirectory(tempExtractPath);
    if (fs.existsSync(finalExtractPath)) deleteDirectory(finalExtractPath);
    connection.release();
  }
};

export default createTemplate;
