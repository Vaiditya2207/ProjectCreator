//
//  AuthPage.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 20/10/24.
//

import SwiftUI

struct AuthPage: View {
    @ObservedObject var model: MainViewModel
    @State private var current: String = "login"
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""

    var body: some View {
        VStack {
            Spacer()
            VStack() {
                if current == "login"{
                    LoginComponent(model: model)
                }else{
                    SignupComponent(model: model)
                }
                HStack{
                    Button(current == "login" ? "Create an account? SignUp" : "Already a user? Login"){
                        current = current == "login" ? "signup" : "login"

                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.top, 1)
                
                Spacer()
            }
            .frame(width: 300, height: 400)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            .padding(.horizontal, 20)
            
            Spacer()
            
            HStack {
                Spacer()
                Text("Powered By Codemelon")
            }
            .padding(.horizontal, 10)
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    AuthPage(model: MainViewModel())
        .frame(minWidth: 600, minHeight: 600)
}
