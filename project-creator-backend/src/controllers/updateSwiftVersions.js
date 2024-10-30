import simpleGit from 'simple-git';
import fs from 'fs-extra';
import path from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const git = simpleGit();

const cloneAndCopyRepo = async () => {
    const repoUrl = 'https://github.com/TemplateLibraryByCodemelon/swift-application-versions';
    const cloneDir = path.join(__dirname, 'temp-repo');
    const targetDir = path.join(__dirname, '../versions');

    try {
        // Remove the clone directory if it exists
        if (fs.existsSync(cloneDir)) {
            await fs.remove(cloneDir);
        }

        // Clone the repository
        await git.clone(repoUrl, cloneDir);

        // Ensure the target directory exists
        if (!fs.existsSync(targetDir)) {
            await fs.mkdirp(targetDir);
        }

        // Copy the contents of the cloned repository to the target directory
        await fs.copy(cloneDir, targetDir);

        return true
    } catch (error) {
        return false
    } finally {
        // Clean up the temporary clone directory
        if (fs.existsSync(cloneDir)) {
            await fs.remove(cloneDir);
        }
    }
};


export default cloneAndCopyRepo;