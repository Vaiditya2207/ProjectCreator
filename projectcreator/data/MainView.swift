import SwiftUI
import Combine
import Foundation

class MainViewModel: ObservableObject {
    @Published var currentComponent: String {
        didSet {
            UserDefaults.standard.set(currentComponent, forKey: "currentComponent")
        }
    }
    
    @Published var isLoggedIn: Bool {
        didSet {
            UserDefaults.standard.set(isLoggedIn, forKey: "isLoggedIn")
            print("Login status changed to: \(isLoggedIn)")
        }
    }
    
    private var userData: String {
        get {
            UserDefaults.standard.string(forKey: "user") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "user")
            print("User data changed")
        }
    }

    var user: User? {
        get {
            if let data = userData.data(using: .utf8) {
                return try? JSONDecoder().decode(User.self, from: data)
            }
            return nil
        }
        set {
            if let newValue = newValue {
                if let data = try? JSONEncoder().encode(newValue) {
                    userData = String(data: data, encoding: .utf8) ?? ""
                }
            } else {
                userData = ""
            }
        }
    }

    init() {
        // Initialize with stored values, defaulting to "HomePage" and false if not set
        self.currentComponent = UserDefaults.standard.string(forKey: "currentComponent") ?? "HomePage"
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        
        // Check for token and update isLoggedIn
        checkAuthToken()
    }

    func updateComponent(component: String) {
        currentComponent = component
    }

    func toggleLogin() {
        isLoggedIn.toggle()
    }

    func createUser(username: String, email: String, password: String, profileUrl: String) {
        user = User(username: username, email: email, password: password, profileUrl: profileUrl)
    }

    func getUserInfo() -> (username: String?, email: String?, profileUrl: String?) {
        guard let user = user else {
            return (nil, nil, nil)
        }
        return (user.username, user.email, user.profileUrl)
    }

    /// Check if the auth token exists in Keychain and update `isLoggedIn` accordingly
    func checkAuthToken() {
        if KeychainHelper.standard.tokenExists(forKey: "authToken") {
            isLoggedIn = true
        } else {
            isLoggedIn = false
        }
    }
    func logout() {
            // Clear token from Keychain and update state
            KeychainHelper.standard.delete(forKey: "authToken")
            isLoggedIn = false
            user = nil
            currentComponent = "AuthPage" // Redirect to AuthPage
        }

    /// Decode JWT and create a User from it
    func decodeJWTAndCreateUser(from token: String) -> User? {
        let components = token.split(separator: ".")
        guard components.count == 3 else { return nil }
        
        // Decode the payload
        if let payloadData = Data(base64Encoded: String(components[1]), options: .ignoreUnknownCharacters),
           let claims = try? JSONDecoder().decode(JWTClaims.self, from: payloadData) {
            // Create a User instance from claims
            return User(username: claims.username, email: claims.email, profileUrl: claims.profileUrl)
        }
        
        return nil
    }
}

struct JWTClaims: Codable {
    let username: String?
    let email: String?
    let profileUrl: String?
}
