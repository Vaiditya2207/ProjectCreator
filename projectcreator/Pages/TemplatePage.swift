import SwiftUI

struct TemplatePage: View {
    let template: Template
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
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
                Label {
                    Text(template.createdDate, style: .date)
                } icon: {
                    Image(systemName: "calendar")
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: {
                // Action to create a project based on this template
                print("Creating project based on \(template.name)")
            }) {
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
    }
}

struct TemplatePage_Previews: PreviewProvider {
    static var previews: some View {
        TemplatePage(template: Template(name: "Swift UI Starter",
                                        description: "A comprehensive starter template for SwiftUI projects with basic MVVM structure.",
                                        author: "John Doe",
                                        type: "iOS App",
                                        createdDate: Date()))
    }
}
