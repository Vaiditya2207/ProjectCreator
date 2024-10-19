import SwiftUI

struct HomeView: View {
    @ObservedObject var model: MainViewModel
    var body: some View{
        VStack{
            switch model.currentComponent{
            case "HomePage":
                HomePage(model: model)
            case "AppSettings":
                AppSettings(model: model)
            case "AuthPage":
                AuthPage(model: model)
            case "CreateTemplate":
                CreateTemplate(model: model)
            case "ProfilePage":
                ProfilePage(model: model)
            case "TemplateLibrary":
                TemplateLibrary(model: model)
            case "PackageManager":
                PackageManager(model: model)
            default:
                HomePage(model: model)
            }
        }
    }
}

#Preview {
    HomeView(model: MainViewModel())
}
