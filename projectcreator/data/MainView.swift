import SwiftUI
import Combine

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
        // Initialize with stored values, defaulting isLoggedIn to false
        self.currentComponent = UserDefaults.standard.string(forKey: "currentComponent") ?? "HomePage"
        self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn") // Defaults to false if not set
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
}
