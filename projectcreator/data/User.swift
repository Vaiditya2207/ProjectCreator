//
//  User.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 20/10/24.
//

import Foundation

struct User: Codable {
    var username: String?
    var email: String?
    var password: String?
    var profileUrl: String?

    var isValid: Bool {
        return isValidEmail(email) && isValidPassword(password)
    }

    private func isValidEmail(_ email: String?) -> Bool {
        guard let email = email else { return false }
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPredicate.evaluate(with: email)
    }

    private func isValidPassword(_ password: String?) -> Bool {
        guard let password = password else { return false }
        return password.count >= 8
    }
}
