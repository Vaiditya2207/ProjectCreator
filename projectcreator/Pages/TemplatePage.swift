import SwiftUI
import Foundation
import ZIPFoundation

// Struct to represent error messages
struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

struct TemplatePage: View {
    let template: Template
    @Environment(\.dismiss) private var dismiss
    @State private var projectName: String = ""
    @State private var selectedDirectory: URL?
    @State private var showingProjectNameAlert = false
    @State private var showDirectoryPicker = false
    @State private var isLoading = false
    @State private var errorMessage: ErrorMessage?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .buttonStyle(PlainButtonStyle())
                Spacer()
            }
            Text(template.name)
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(template.description)
                .font(.body)
                .foregroundColor(.secondary)
            HStack {
                Label(template.author, systemImage: "person")
                Spacer()
                if let date = template.formattedCreatedDate {
                    Label { Text(date, style: .date) } icon: { Image(systemName: "calendar") }
                } else {
                    Text("Invalid Date")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            Spacer()
            Button(action: { showingProjectNameAlert = true }) {
                Text("Create Project")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .alert("Enter Project Name", isPresented: $showingProjectNameAlert) {
            TextField("Project Name", text: $projectName)
            Button("Next") {
                showingProjectNameAlert = false
                showDirectoryPicker = true
            }
            Button("Cancel", role: .cancel) { showingProjectNameAlert = false }
        }
        .sheet(isPresented: $showDirectoryPicker) {
            DirectoryPicker(selectedDirectory: $selectedDirectory, isPresented: $showDirectoryPicker, onComplete: downloadAndSetupProject)
        }
        .overlay(
            Group {
                if isLoading {
                    ProgressView("Creating project...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5))
                        .foregroundColor(.white)
                }
            }
        )
        .alert(item: $errorMessage) { errorMessage in
            Alert(title: Text("Error"), message: Text(errorMessage.message), dismissButton: .default(Text("OK")))
        }
    }

    func downloadAndSetupProject() {
        guard !projectName.isEmpty, let selectedDirectory = selectedDirectory else {
            errorMessage = ErrorMessage(message: "Project name or directory not selected.")
            return
        }

        // Construct the ZIP file URL by replacing `.git` in `template.url`
        guard let repoURL = URL(string: template.url) else {
            errorMessage = ErrorMessage(message: "Invalid template URL.")
            return
        }

        // Create ZIP URL by replacing `.git` and appending `/archive/refs/heads/main.zip`
        var zipURLString = repoURL.absoluteString
        if zipURLString.hasSuffix(".git") {
            zipURLString = String(zipURLString.dropLast(4)) // Remove the last 4 characters (".git")
        }
        zipURLString += "/archive/refs/heads/main.zip" // Append the correct path

        guard let zipURL = URL(string: zipURLString) else {
            errorMessage = ErrorMessage(message: "Invalid ZIP URL.")
            return
        }

        print("ZIP URL: \(zipURL)") // Debugging line to verify the generated URL

        isLoading = true  // Show loading indicator
        URLSession.shared.downloadTask(with: zipURL) { location, response, error in
            DispatchQueue.main.async {
                self.isLoading = false  // Hide loading indicator
            }

            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = ErrorMessage(message: "Download failed: \(error.localizedDescription)")
                }
                return
            }

            guard let location = location else {
                DispatchQueue.main.async {
                    self.errorMessage = ErrorMessage(message: "Download location is invalid.")
                }
                return
            }

            do {
                // Create the destination URL for the ZIP file
                let zipFileURL = selectedDirectory.appendingPathComponent("template.zip")
                try FileManager.default.moveItem(at: location, to: zipFileURL)

                // Verify the downloaded file is a valid ZIP file
                let fileData = try Data(contentsOf: zipFileURL)
                if !fileData.starts(with: [0x50, 0x4B]) { // Check for ZIP magic numbers (PK)
                    throw NSError(domain: "UnzippingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Downloaded file is not a valid ZIP archive."])
                }

                guard let archive = Archive(url: zipFileURL, accessMode: .read) else {
                    throw NSError(domain: "UnzippingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to create Archive instance."])
                }

                // Check if the archive contains entries
                if archive.makeIterator().next() == nil {
                    throw NSError(domain: "UnzippingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "ZIP archive is empty."])
                }

                // Extract the ZIP content to the selected directory
                try FileManager.default.createDirectory(at: selectedDirectory, withIntermediateDirectories: true)
                try FileManager.default.unzipItem(at: zipFileURL, to: selectedDirectory)

                // Assuming the extracted folder name is formatted as "templatenamebytemplateAuthor-main"
                let expectedFolderName = "\(template.name)by\(template.author)-main"
                let extractedFolderURL = selectedDirectory.appendingPathComponent(expectedFolderName)
                let newFolderURL = selectedDirectory.appendingPathComponent(projectName)

                // Check for the folder based on the exact name of the extracted folder
                if FileManager.default.fileExists(atPath: extractedFolderURL.path) {
                    // Rename the extracted folder to the project name
                    try FileManager.default.moveItem(at: extractedFolderURL, to: newFolderURL)
                } else {
                    throw NSError(domain: "RenamingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Extracted folder named '\(expectedFolderName)' not found."])
                }

                try FileManager.default.removeItem(at: zipFileURL)  // Remove ZIP after extraction

                openInVSCode(directory: newFolderURL)
                increaseProjectCount()

            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = ErrorMessage(message: "Error creating project: \(error.localizedDescription)")
                }
            }
        }.resume()
    }





    func openInVSCode(directory: URL) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", "Visual Studio Code", directory.path]
        task.launch()
    }

    func increaseProjectCount() {
        guard let url = URL(string: "https://projectcreator.onrender.com/api/increase-project-count/\(template.id)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request).resume()
    }
}

struct DirectoryPicker: View {
    @Binding var selectedDirectory: URL?
    @Binding var isPresented: Bool
    var onComplete: () -> Void

    var body: some View {
        VStack {
            Text("Choose Directory")
                .font(.headline)
            Button("Select Folder") {
                let panel = NSOpenPanel()
                panel.canChooseDirectories = true
                panel.canCreateDirectories = true
                panel.begin { response in
                    if response == .OK {
                        selectedDirectory = panel.url
                        isPresented = false
                        onComplete() // Trigger the download and setup after selecting directory
                    }
                }
            }
        }
        .padding()
        .frame(width: 300, height: 150)
    }
}

struct TemplatePage_Previews: PreviewProvider {
    static var previews: some View {
        TemplatePage(template: Template(
            id: 1,
            name: "Swift UI Starter",
            description: "A comprehensive starter template for SwiftUI projects with basic MVVM structure.",
            author: "John Doe",
            type: "iOS App",
            url: "https://github.com/TemplateLibraryByCodemelon/Somethingbyadmin1.git",
            createdDate: "2024-10-27T12:55:48.000Z"))
    }
}
