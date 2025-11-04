//
//  PrimaryButton.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 03/11/2025.
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.gradient)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: color.opacity(0.3), radius: 8, y: 5)
        }
    }
}
#Preview {
    PrimaryButton(title: "Big Test", color: .accentColor, action: {})
        .padding(24)
}
