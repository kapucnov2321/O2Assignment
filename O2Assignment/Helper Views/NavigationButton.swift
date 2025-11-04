//
//  NavigationButton.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 03/11/2025.
//

import SwiftUI

struct NavigationButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.gradient)
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: color.opacity(0.3), radius: 10, y: 5)
        }
    }
}
#Preview {
    NavigationButton(title: "Little Test", color: .accentColor, action: {})
        .padding(24)
}
