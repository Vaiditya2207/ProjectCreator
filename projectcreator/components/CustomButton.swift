//
//  CustomButton.swift
//  projectcreator
//
//  Created by Vaiditya Tanwar on 19/10/24.
//
import SwiftUI

struct CustomButton: View {
    var title: String
    var width: CGFloat
    var height: CGFloat
    var action: () -> Void

    var body: some View {
        GeometryReader { geometry in
            Button(action: action) {
                Text(title)
                    .frame(width: min(width, geometry.size.width), height: min(height, geometry.size.height))
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: height, maxHeight: height) // Allows flexible sizing
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton(title: "Click Me", width: 250, height: 60) {
            print("Something")
        }
        .padding() // Optional: Add padding around the button for better preview
        .previewLayout(.sizeThatFits) // For better preview in various layouts
    }
}
