import SwiftUI
import Combine
import Network

// MARK: - Model
struct Template: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let author: String
    let type: String
    let url: String
    let createdDate: String

    enum CodingKeys: String, CodingKey {
        case id
        case name = "templateName"
        case description = "templateDescription"
        case author = "templateAuthor"
        case type = "templateType"
        case url = "templateUrl"
        case createdDate = "createdAt"
    }
    
    var formattedCreatedDate: Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Allow for fractional seconds
        if let date = dateFormatter.date(from: createdDate) {
            return date
        } else {
            print("Failed to parse date: \(createdDate)")
            return nil
        }
    }
}

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    @Published var isConnected = true

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

// MARK: - ViewModel
class TemplateViewModel: ObservableObject {
    @Published var templates: [Template] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = true
    @Published var error: String? = nil
    
    init() {
        fetchTemplates()
    }

    func fetchTemplates() {
        guard let url = URL(string: "https://projectcreator.onrender.com/api/get-all-templates") else {
            self.error = "Invalid URL configuration"
            self.isLoading = false
            return
        }
        
        print("Debug - Request started for URL: \(url)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    print("Debug - Network error: \(error.localizedDescription)")
                    self?.error = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Debug - Invalid response")
                    self?.error = "Invalid server response"
                    return
                }
                
                print("Debug - Status code: \(httpResponse.statusCode)")
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("Debug - HTTP Error: \(httpResponse.statusCode)")
                    self?.error = "Server error: \(httpResponse.statusCode)"
                    return
                }
                
                guard let data = data else {
                    print("Debug - No data received")
                    self?.error = "No data received"
                    return
                }
                
                // Log the response data
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Debug - Received JSON: \(jsonString)")
                }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let templates = try decoder.decode([Template].self, from: data)
                    print("Debug - Successfully decoded \(templates.count) templates")
                    self?.templates = templates
                    self?.error = nil
                } catch {
                    print("Debug - Decoding error: \(error.localizedDescription)")
                    self?.error = "Failed to decode data: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    var filteredTemplates: [Template] {
        if searchText.isEmpty {
            return templates
        } else {
            return templates.filter { template in
                template.name.lowercased().contains(searchText.lowercased()) ||
                template.author.lowercased().contains(searchText.lowercased()) ||
                template.type.lowercased().contains(searchText.lowercased())
            }
        }
    }
}

// MARK: - Views
struct TemplateLibrary: View {
    @StateObject private var viewModel = TemplateViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var sortOrder: [KeyPathComparator<Template>] = [
        .init(\.name, order: SortOrder.forward)
    ]
    @State private var selectedTemplateID: Set<Int> = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isLoading {
                    ProgressView("Loading templates...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let error = viewModel.error {
                    VStack(spacing: 16) {
                        Text(error)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.isLoading = true
                            viewModel.fetchTemplates()
                        }
                    }
                    .padding()
                } else {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search", text: $viewModel.searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(6)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
                    .padding([.horizontal, .top])

                    // Table
                    Table(viewModel.filteredTemplates, selection: $selectedTemplateID, sortOrder: $sortOrder) {
                        TableColumn("Name", value: \.name) { template in
                            HStack {
                                Image(systemName: "doc")
                                    .foregroundColor(.blue)
                                Text(template.name)
                            }
                        }
                        .width(ideal: 200)

                        TableColumn("Author", value: \.author)
                            .width(ideal: 150)

                        TableColumn("Type", value: \.type)
                            .width(ideal: 100)

                        TableColumn("Created At") { template in
                            if let date = template.formattedCreatedDate {
                                Text(date, style: .date)
                            } else {
                                Text("Invalid Date")
                            }
                        }
                        .width(ideal: 150)
                    }
                }
            }
            .frame(minWidth: 600, minHeight: 400)
            .background(Color(NSColor.controlBackgroundColor))
            .navigationDestination(isPresented: Binding(
                get: { !selectedTemplateID.isEmpty },
                set: { if !$0 { selectedTemplateID.removeAll() } }
            )) {
                if let id = selectedTemplateID.first, let template = viewModel.templates.first(where: { $0.id == id }) {
                    TemplatePage(template: template)
                }
            }
        }
        .onChange(of: networkMonitor.isConnected) { _, newValue in
            if newValue && viewModel.error != nil {
                viewModel.isLoading = true
                viewModel.fetchTemplates()
            }
        }
    }
}

// Preview provider for TemplateLibrary view
struct TemplateLibrary_Previews: PreviewProvider {
    static var previews: some View {
        TemplateLibrary()
    }
}
