//
//  ContentView.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 19/10/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = MainViewModel()

    var body: some View {
        HStack(spacing: 0) {
            SideBar(model: viewModel)
                .frame(minWidth: 200)
                .background(Color.gray.opacity(0.2))
                .overlay(
                    Rectangle()
                        .frame(width: 1)
                        .foregroundColor(Color.gray.opacity(0.5))
                        .offset(x: (202 / 2))
                )
            
            HomeView()
                .frame(maxWidth: .infinity)
        }
        .frame(maxHeight: .infinity)
        .background(Color.gray.opacity(0.1))
    }
}

#Preview {
    ContentView()
        .frame(minWidth: 800, minHeight: 600)
}
