import SwiftUI

struct SideBar: View {
    @ObservedObject var model: MainViewModel  // Use @ObservedObject here
    
    var body: some View {
        var isLoggedIn = model.isLoggedIn
        VStack(alignment: .leading, spacing: 20) {
            Button(action: {
                model.currentComponent = "HomePage"
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "house")
                        .frame(width: 20)
                    Text("Home Page")
                }
                .padding(.horizontal, 5)
            }
            .frame(maxWidth: 170, alignment: .leading)
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                model.currentComponent = "PackageManager"
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "tray")
                        .frame(width: 20)
                    Text("Package Manager")
                }
                .padding(.horizontal, 5)
            }
            .frame(maxWidth: 170, alignment: .leading)
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                model.currentComponent = "TemplateLibrary"
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "building.columns")
                        .frame(width: 20)
                    Text("Template Library")
                }
                .padding(.horizontal, 5)
            }
            .frame(maxWidth: 170, alignment: .leading)
            .buttonStyle(PlainButtonStyle())

            Button(action: {
                model.currentComponent = "CreateTemplate"
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "externaldrive.badge.plus")
                        .frame(width: 20)
                    Text("Create Template")
                }
                .padding(.horizontal, 5)
            }
            .frame(maxWidth: 170, alignment: .leading)
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button(action: {
                model.currentComponent = "AppSettings"
            }) {
                HStack(spacing: 5) {
                    Image(systemName: "gear")
                        .frame(width: 20)
                    Text("Settings")
                }
                .padding(.horizontal, 5)
            }
            .frame(maxWidth: 170, alignment: .leading)
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                model.currentComponent = isLoggedIn ? "ProfilePage": "AuthPage"
            }) {
                HStack(spacing: 5) {
                    
                    Image(systemName: isLoggedIn ? "person.circle" : "touchid")
                        .frame(width: 20)
                    Text(isLoggedIn ? "Profile Page" : "Log In")
                }
                .padding(.horizontal, 5)
            }
            .frame(maxWidth: 170, alignment: .leading)
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxHeight: .infinity)
        .padding(.vertical, 20)
        .onReceive(model.$isLoggedIn){newValue in
            isLoggedIn = model.isLoggedIn
        }
    }
}


#Preview {
    SideBar(model: MainViewModel())
}
