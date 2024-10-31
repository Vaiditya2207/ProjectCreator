const model = `
    CREATE TABLE IF NOT EXISTS userVerificationJunction (
        id INT AUTO_INCREMENT PRIMARY KEY,
        userId INT NOT NULL,
        verificationId INT NOT NULL,
        vericationCode VARCHAR(255) NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id),
    )
`


export default model;