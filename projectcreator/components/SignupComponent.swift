//
//  SignupComponent.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 21/10/24.
//

import SwiftUI

struct SignupComponent: View {
    @ObservedObject var model: MainViewModel
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false  // Loading state

    var body: some View {
        VStack {
            Spacer()
            Text("CodeMelon")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 40)
                
                TextField("Username", text: $username)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 10)
            }
            .padding(.horizontal, 30)
            
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 40)
                
                TextField("Email", text: $email)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 10)
            }
            .padding(.horizontal, 30)
            
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 40)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.horizontal, 10)
            }
            .padding(.bottom, 10)
            .padding(.horizontal, 30)
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
            HStack {
                Button(action: signUp) {
                    Text("Create Account")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 30)
                .disabled(isLoading)  // Disable button while loading
            }
            .padding(.bottom, 10)
            
            Text("-------------- OR --------------")
            
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
            Spacer()
        }
    }
    
    private func signUp() {
        guard let url = URL(string: "https://projectcreator.onrender.com/api/auth/signup") else {
            return
        }
        
        isLoading = true  // Start loading

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "username": username,
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false  // Stop loading
            }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    showError = true
                    errorMessage = "Network error. Please try again."
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let token = json["token"] as? String {
                        DispatchQueue.main.async {
                            showError = false
                            KeychainHelper.standard.save(token, forKey: "authToken")
                            
                            // Decode the token and update the user in MainViewModel
                            if let user = model.decodeJWTAndCreateUser(from: token) {
                                model.user = user
                            }
                            if let isAdmin = json["isAdmin"] as? Bool {
                                model.isAdmin = isAdmin
                            }
                            model.checkAuthToken()
                            model.currentComponent = "HomePage"
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        showError = true
                        errorMessage = "Failed to decode response."
                    }
                }
            } else {
                DispatchQueue.main.async {
                    showError = true
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let message = json["message"] as? String {
                        errorMessage = message
                    } else {
                        errorMessage = "Sign up failed. Please try again."
                    }
                }
            }
        }.resume()
    }
}
