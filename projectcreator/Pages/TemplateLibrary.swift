//
//  TemplateLibrary.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 20/10/24.
//

import SwiftUI

struct Template: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let author: String
    let type: String
    let createdDate: Date
}

class TemplateViewModel: ObservableObject {
    @Published var templates: [Template] = [
        Template(name: "Swift UI Starter",
                 description: "A comprehensive starter template for SwiftUI projects with basic MVVM structure.",
                 author: "John Doe",
                 type: "iOS App",
                 createdDate: Date().addingTimeInterval(-86400 * 7)),
        Template(name: "Core Data Template",
                 description: "A template with Core Data integration for persistent storage in iOS apps.",
                 author: "Jane Smith",
                 type: "iOS App",
                 createdDate: Date().addingTimeInterval(-86400 * 14)),
        Template(name: "SwiftUI Game Template",
                 description: "A template for creating 2D games using SwiftUI and SpriteKit.",
                 author: "Mike Johnson",
                 type: "iOS Game",
                 createdDate: Date().addingTimeInterval(-86400 * 21))
    ]
    
    @Published var searchText: String = ""
    
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

import SwiftUI

struct TemplateLibrary: View {
    @ObservedObject var model: MainViewModel // Assuming this comes from elsewhere
    @ObservedObject var viewModel: TemplateViewModel
    @State private var sortOrder: [KeyPathComparator<Template>] = [
        .init(\.name, order: SortOrder.forward)
    ]
    @State private var selectedTemplateID: UUID?

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
                        Text(template.createdDate, style: .date)
                    }
                    .width(ideal: 150)
                }
            }
            .frame(minWidth: 600, minHeight: 400)
            .background(Color(NSColor.controlBackgroundColor))
            .navigationDestination(isPresented: Binding(
                get: { selectedTemplateID != nil },
                set: { if !$0 { selectedTemplateID = nil } }
            )) {
                if let id = selectedTemplateID, let template = viewModel.templates.first(where: { $0.id == id }) {
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
