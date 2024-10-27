//
//  TemplateLibrary.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 20/10/24.
//

import SwiftUI
import Combine

struct Template: Identifiable, Codable {
    let id: Int
    let name: String
    let description: String
    let author: String
    let type: String
    let url: String
    let createdDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name = "templateName"
        case description = "templateDescription"
        case author = "templateAuthor"
        case type = "templateType"
        case url = "templateUrl"
        case createdDate = "createdAt"
    }
}

class TemplateViewModel: ObservableObject {
    @Published var templates: [Template] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = true // Loader state
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchTemplates()
    }

    func fetchTemplates() {
        guard let url = URL(string: "https://projectcreator.onrender.com/api/get-all-templates") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Template].self, decoder: JSONDecoder.customDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch templates: \(error.localizedDescription)")
                }
                self?.isLoading = false // Stop loading when fetch is complete
            }, receiveValue: { [weak self] templates in
                self?.templates = templates
            })
            .store(in: &cancellables)
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

extension JSONDecoder {
    static func customDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}

struct TemplateLibrary: View {
    @ObservedObject var model: MainViewModel // Assuming this comes from elsewhere
    @ObservedObject var viewModel: TemplateViewModel
    @State private var sortOrder: [KeyPathComparator<Template>] = [
        .init(\.name, order: SortOrder.forward)
    ]
    @State private var selectedTemplateID: Set<Int> = [] // Update selection to Set<Int>

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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

                // Loading Indicator
                if viewModel.isLoading {
                    ProgressView("Loading templates...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    // Table
                    Table(viewModel.filteredTemplates, selection: Binding(get: { selectedTemplateID }, set: { selectedTemplateID = $0 }), sortOrder: $sortOrder) {
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
                            Text(template.createdDate, style: .date)
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
    }
}

struct TemplateLibrary_Previews: PreviewProvider {
    static var previews: some View {
        TemplateLibrary(model: MainViewModel(), viewModel: TemplateViewModel())
    }
}
