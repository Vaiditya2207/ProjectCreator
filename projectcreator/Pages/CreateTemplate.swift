//
//  CreateTemplate.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 20/10/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct CreateTemplate: View {
    @ObservedObject var model: MainViewModel
    
    @State private var templateName: String = ""
    @State private var templateDescription: String = ""
    @State private var templateType: String = "Backend"  // Default type
    @State private var fileURL: URL?  // URL for the file to be uploaded
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false  // Loading state
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Create Template")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Template Name", text: $templateName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Template Description", text: $templateDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Picker("Template Type", selection: $templateType) {
                Text("Backend").tag("Backend")
                Text("Frontend").tag("Frontend")
                Text("Fullstack").tag("Fullstack")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            Button(action: selectFile) {
                Text("Select File")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            if fileURL != nil {
                Text("Selected file: \(fileURL!.lastPathComponent)")
                    .padding(.horizontal)
                    .foregroundColor(.green)
            }
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
            
            Button(action: submitTemplate) {
                Text("Submit")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .disabled(isLoading || fileURL == nil)  // Disable if loading or no file selected
            
            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
        }
        .onAppear {
            checkAuth()
        }
    }
    
    private func selectFile() {
        // Use NSOpenPanel for macOS to select a file
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.zip]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK {
            fileURL = panel.url
        }
    }
    
    private func checkAuth() {
        // Check if the user has a valid auth token
        if !KeychainHelper.standard.tokenExists(forKey: "authToken") {
            model.currentComponent = "AuthPage"
        }
    }
    
    private func submitTemplate() {
        guard let fileURL = fileURL else {
            showError = true
            errorMessage = "Please select a file."
            return
        }
        
        guard let token = KeychainHelper.standard.read(forKey: "authToken") else {
            model.currentComponent = "AuthPage"
            return
        }
        
        guard let url = URL(string: "https://projectcreator.onrender.com/api/create-template") else {
            showError = true
            errorMessage = "Invalid URL."
            return
        }
        
        isLoading = true
        showError = false
        errorMessage = ""
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Prepare the multipart/form-data request
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add template name
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"templateName\"\r\n\r\n")
        body.append("\(templateName)\r\n")
        
        // Add template description
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"templateDescription\"\r\n\r\n")
        body.append("\(templateDescription)\r\n")
        
        // Add template type
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"templateType\"\r\n\r\n")
        body.append("\(templateType)\r\n")
        
        // Add the token
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"token\"\r\n\r\n")
        body.append("\(token)\r\n")
        
        // Add the file data
        if let fileData = try? Data(contentsOf: fileURL) {
            let filename = fileURL.lastPathComponent
            let mimetype = "application/zip"
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(fileData)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    showError = true
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    showError = true
                    errorMessage = "Unexpected response"
                }
                return
            }
            
            if httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    showError = false
                    model.currentComponent = "HomePage"  // Navigate to the home page after success
                }
            } else {
                DispatchQueue.main.async {
                    showError = true
                    errorMessage = "Failed to create template. Please check the details and try again."
                }
            }
        }.resume()
    }
}

// Helper extension to append data to Data objects
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
