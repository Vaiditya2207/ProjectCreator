//
//  HomePage.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 20/10/24.
//

import SwiftUI

struct HomePage: View {
    @ObservedObject var model: MainViewModel
    @State private var animatedText: String = ""
    let greetingsArray: [String] = ["Hi", "Hello", "Namaste", "Hey", "Greetings", "Salutations", "Hola", "Bonjour", "Ciao", "Konnichiwa"]
    private var fullGreeting: String {
        let randomGreeting = greetingsArray.randomElement() ?? "Hi"
        return "\(randomGreeting) \(model.getUserInfo().username ?? "Developer") ..."
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text(animatedText)
                    .bold()
                    .font(.system(size: 22))
                    .animation(.easeInOut(duration: 0.001), value: animatedText) // Smooth animation
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    
                }){
                    VStack{
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(.bottom, 10)
                        Text("Create Project")
                    }
                    .frame(minWidth: 200, minHeight: 110)
                    .buttonStyle(PlainButtonStyle())
                }
                .cornerRadius(20)
                .shadow(radius: 5)
                Spacer()
                Button(action: {
                    model.currentComponent = "TemplateLibrary"
                }){
                    VStack{
                        Image(systemName: "building.columns")
                            .resizable()
                            .frame(width: 16, height: 15)
                            .padding(.bottom, 10)
                        Text("Template Library")
                    }
                    .frame(minWidth: 200, minHeight: 110)
                }
                .cornerRadius(20)
                .shadow(radius: 5)
                Spacer()
            }
            .padding(.bottom, 15)
            HStack {
                Spacer()
                Button(action: {
                    model.currentComponent = "PackageManager"
                }){
                    VStack{
                        Image(systemName: "tray")
                            .resizable()
                            .frame(width: 22, height: 15)
                            .padding(.bottom, 10)
                        Text("Package Manager")
                    }
                    .frame(minWidth: 200, minHeight: 110)
                    .buttonStyle(PlainButtonStyle())
                }
                .cornerRadius(20)
                .shadow(radius: 5)
                Spacer()
                Button(action: {
                    
                }){
                    VStack{
                        Image(systemName: "house.lodge")
                            .resizable()
                            .frame(width: 25, height: 15)
                            .padding(.bottom, 10)
                        Text("About CodeMelon")
                    }
                    .frame(minWidth: 200, minHeight: 110)
                    .buttonStyle(PlainButtonStyle())
                }
                .cornerRadius(20)
                .shadow(radius: 5)
                Spacer()
            }
            .padding(.bottom, 15)
            HStack {
                Spacer()
                Button(action: {
                    model.currentComponent = "CreateTemplate"
                }){
                    VStack{
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .padding(.bottom, 10)
                        Text("Create Your Own Template")
                    }
                    .frame(minWidth: 200, minHeight: 110)
                    .buttonStyle(PlainButtonStyle())
                }
                .cornerRadius(20)
                .shadow(radius: 5)
                Spacer()
            }
            Spacer()
            HStack{
                Spacer()
                Text("Powered By Codemelon")
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 10)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        animatedText = ""
        var currentIndex = 0
        let fullText = fullGreeting
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            if currentIndex < fullText.count {
                let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                animatedText.append(fullText[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

#Preview {
    HomePage(model: MainViewModel())
        .frame(minWidth: 600, minHeight: 600)
}

