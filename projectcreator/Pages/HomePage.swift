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
            HStack{
                Spacer()
                Text("Powered By Codemelon")
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 30)
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
