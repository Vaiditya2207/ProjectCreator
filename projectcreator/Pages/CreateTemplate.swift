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
    @Environment(\.colorScheme) var colorScheme
    
    @State private var templateName: String = ""
    @State private var templateDescription: String = ""
    @State private var templateType: TemplateType = .backend
    @State private var fileURL: URL?
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    
    enum TemplateType: String, CaseIterable {
        case backend = "Backend"
        case frontend = "Frontend"
        case fullstack = "Fullstack"
        case mobile = "Mobile"
        case dataScience = "Data Science"
        case devOps = "DevOps"
        case security = "Security"
        case iot = "IoT"
        case aiMl = "AI/ML"
        case testing = "Testing"
        
        var icon: String {
            switch self {
            case .backend: return "server.rack"
            case .frontend: return "paintbrush"
            case .fullstack: return "laptopcomputer"
            case .mobile: return "iphone"
            case .dataScience: return "chart.bar.xaxis"
            case .devOps: return "gearshape.2"
            case .security: return "lock.shield"
            case .iot: return "sensor"
            case .aiMl: return "cpu"
            case .testing: return "checkmark.circle"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Create Template")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Create a new project template for your team")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, geometry.size.height * 0.03)
                
                // Form Fields
                VStack(alignment: .leading, spacing: geometry.size.height * 0.025) {
                    FormField(title: "Template Name", text: $templateName)
                        .frame(height: geometry.size.height * 0.08)
                    
                    FormField(title: "Description", text: $templateDescription, isMultiline: true)
                        .frame(height: geometry.size.height * 0.15)
                    
                    // Template Type Dropdown
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Template Type")
                            .font(.headline)
                        
                        Menu {
                            ForEach(TemplateType.allCases, id: \.self) { type in
                                Button(action: { templateType = type }) {
                                    HStack {
                                        Image(systemName: type.icon)
                                        Text(type.rawValue)
                                        if templateType == type {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: templateType.icon)
                                Text(templateType.rawValue)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(.top, 10)
                        .frame(height: geometry.size.height * 0.06)
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    // File Selection
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Template File")
                            .font(.headline)
                        
                        Button(action: selectFile) {
                            HStack {
                                Image(systemName: "doc.badge.plus")
                                Text(fileURL == nil ? "Select ZIP File" : "Change File")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundColor(.accentColor)
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.top, 50)
                        .frame(height: geometry.size.height * 0.06)
                        
                        if let fileURL = fileURL {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(fileURL.lastPathComponent)
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                            .padding(.top, 4)
                        }
                    }
                    
                    Spacer(minLength: geometry.size.height * 0.02)
                    
                    // Error Message
                    if showError {
                        Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    Spacer(minLength: geometry.size.height * 0.02)
                    
                    // Submit Button
                    Button(action: submitTemplate) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isLoading ? "Creating Template..." : "Create Template")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .frame(height: geometry.size.height * 0.06)
                        .background(buttonBackground)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(isLoading || fileURL == nil || templateName.isEmpty)
                }
            }
            .padding(geometry.size.width * 0.04)
        }
        .onAppear(){
            if !KeychainHelper.standard.tokenExists(forKey: "authToken") {
                model.currentComponent = "AuthPage"
            }
        }
    }
    
    private var buttonBackground: Color {
        if isLoading || fileURL == nil || templateName.isEmpty {
            return Color.gray
        }
        return Color.accentColor
    }
    
    // Form Field Component
    private struct FormField: View {
        let title: String
        @Binding var text: String
        var isMultiline: Bool = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                if isMultiline {
                    TextEditor(text: $text)
                        .padding(4)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                } else {
                    TextField(title, text: $text)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(8)
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
            }
        }
    }
    
    private func selectFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType.zip]
        panel.allowsMultipleSelection = false
        if panel.runModal() == .OK {
            fileURL = panel.url
        }
    }
    
    private func checkAuth() {
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
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Helper function to append string to Data
        func append(_ string: String) {
            guard let data = string.data(using: .utf8) else { return }
            body.append(data)
        }
        
        // Add template name
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"templateName\"\r\n\r\n")
        append("\(templateName)\r\n")
        
        // Add template description
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"templateDescription\"\r\n\r\n")
        append("\(templateDescription)\r\n")
        
        // Add template type
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"templateType\"\r\n\r\n")
        append("\(templateType.rawValue)\r\n")
        
        // Add the token
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"token\"\r\n\r\n")
        append("\(token)\r\n")
        
        // Add the file data
        if let fileData = try? Data(contentsOf: fileURL) {
            let filename = fileURL.lastPathComponent
            let mimetype = "application/zip"
            
            append("--\(boundary)\r\n")
            append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n")
            append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(fileData)
            append("\r\n")
        }
        
        append("--\(boundary)--\r\n")
        request.httpBody = body
        
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
            
            if httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    showError = false
                    model.currentComponent = "HomePage"
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

#Preview {
    CreateTemplate(model: MainViewModel())
        .frame(minWidth: 600, minHeight: 600)
}
