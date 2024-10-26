import multer from 'multer';
import AdmZip from 'adm-zip';
import { Octokit } from 'octokit';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';
import simpleGit from 'simple-git';
import pool from '../db/config.js'

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
dotenv.config();
const upload = multer({ dest: 'uploads/' });

const octokit = new Octokit({
  auth: process.env.GITHUB_KEY,
});

// Helper function to delete directory recursively
const deleteDirectory = (dirPath) => {
  if (fs.existsSync(dirPath)) {
    fs.readdirSync(dirPath).forEach((file) => {
      const curPath = path.join(dirPath, file);
      if (fs.lstatSync(curPath).isDirectory()) {
        deleteDirectory(curPath);
      } else {
        fs.unlinkSync(curPath);
      }
    });
    fs.rmdirSync(dirPath);
  }
};

const createTemplate = async (req, res) => {
  const connection = await pool.getConnection()
  const [result] = await connection.query(`SELECT * FROM templateLibrary WHERE templateName = "${req.body.templateName}" AND templateAuthor = "${req.body.templateAuthor}"`)
  if (!req.file || !req.body.templateName || !req.body.templateDescription || !req.body.templateAuthor || !req.body.templateType) {
    return res.status(400).json({
      message: "All fields are required",
      error: "All fields are required"
    });
  }
  if (result.length != 0) {
    return res.status(400).json({
        message: "Already same template by the user",
        error: "Already same template by the user"
    })    
  }    
  const tempExtractPath = path.join(__dirname, 'extracted_temp');
  const finalExtractPath = path.join(__dirname, 'extracted', req.body.templateName + "by" + req.body.authorName );
  let uploadedFilePath = null;

  try {
    uploadedFilePath = req.file.path;

    // Create temporary extraction directory
    if (!fs.existsSync(path.join(__dirname, 'extracted'))) {
      fs.mkdirSync(path.join(__dirname, 'extracted'));
    }
    
    if (!fs.existsSync(tempExtractPath)) {
      fs.mkdirSync(tempExtractPath);
    }

    const zip = new AdmZip(uploadedFilePath);
    
    // Extract to temporary location
    zip.extractAllTo(tempExtractPath, true);

    // Remove __MACOSX folder if it exists
    const macOSXFolder = path.join(tempExtractPath, '__MACOSX');
    if (fs.existsSync(macOSXFolder)) {
      deleteDirectory(macOSXFolder);
    }

    // Find the actual content folder (first directory in temp extraction)
    const extractedContents = fs.readdirSync(tempExtractPath).filter(
      file => fs.statSync(path.join(tempExtractPath, file)).isDirectory()
    )[0];

    // Create final destination folder
    if (!fs.existsSync(finalExtractPath)) {
      fs.mkdirSync(finalExtractPath, { recursive: true });
    }

    // Move contents from nested folder to final destination
    const contentPath = path.join(tempExtractPath, extractedContents);
    fs.readdirSync(contentPath).forEach(file => {
      fs.renameSync(
        path.join(contentPath, file),
        path.join(finalExtractPath, file)
      );
    });

    const repoName = req.body.templateName + "by" + req.body.templateAuthor;
    // Create GitHub repository
    const repoResponse = await octokit.rest.repos.createInOrg({
      org: 'TemplateLibraryByCodemelon',
      name: `${repoName}`,
      private: false,
    });

    const repoUrl = repoResponse.data.clone_url;

    // Initialize and push to GitHub
    const git = simpleGit(finalExtractPath);
    await git.init();
    
    // Check if remote exists and remove it
    const remotes = await git.getRemotes();
    if (remotes.find(remote => remote.name === 'origin')) {
      await git.removeRemote('origin');
    }
    
    await git.addRemote('origin', repoUrl);
    await git.add('.');
    await git.commit('Initial commit');
    
    // Ensure we're on main branch
    try {
      await git.checkoutLocalBranch('main');
    } catch (error) {
      console.log('Branch main already exists or other branch error');
    }
    
    await git.push('origin', 'main', ['--force']);

    // Clean up
    if (uploadedFilePath && fs.existsSync(uploadedFilePath)) {
      fs.unlinkSync(uploadedFilePath); // Remove uploaded ZIP
    }
    if (fs.existsSync(tempExtractPath)) {
      deleteDirectory(tempExtractPath); // Remove temporary extraction directory
    }
    if (fs.existsSync(finalExtractPath)) {
      deleteDirectory(finalExtractPath); // Remove final extraction directory
    }

    await connection.query("INSERT INTO templateLibrary (templateName, templateDescription, templateAuthor, templateType, templateUrl) VALUES (?, ?, ?, ?, ?)", [req.body.templateName, req.body.templateDescription, req.body.templateAuthor, req.body.templateType, repoUrl])
    res.status(201).json({ message: 'Template created successfully!', repoUrl });
  } catch (error) {
    console.error(error);
    
    // Clean up in case of error
    if (uploadedFilePath && fs.existsSync(uploadedFilePath)) {
      fs.unlinkSync(uploadedFilePath);
    }
    if (fs.existsSync(tempExtractPath)) {
      deleteDirectory(tempExtractPath);
    }
    if (fs.existsSync(finalExtractPath)) {
      deleteDirectory(finalExtractPath);
    }
    
    res.status(500).json({ message: 'Error creating template', error: error.message });
  } finally {
    connection.release()
  }
};

export default createTemplate;