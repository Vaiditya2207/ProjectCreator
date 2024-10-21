//
//  LoginComponent.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 21/10/24.
//

import SwiftUI

struct LoginComponent: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""

    var body: some View {
        Spacer()
        Text("CodeMelon")
            .font(.title)
            .fontWeight(.bold)

        Spacer()

        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 40)

            TextField("Email or Username", text: $email)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 10)
        }
        .padding(.horizontal, 30)

        ZStack {
            RoundedRectangle(cornerRadius: 0)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 40)

            SecureField("Password", text: $password)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 10)
        }
        .foregroundColor(Color.black)
        .padding(.bottom, 10)
        .padding(.horizontal, 30)

        HStack {
            Button(action: {
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 30)
        }
        .padding(.bottom, 10)
        
        Text("-------------- OR --------------")

        HStack {
            Button("Forgotten your password ?") {
                
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.top, 10)
    }
}
