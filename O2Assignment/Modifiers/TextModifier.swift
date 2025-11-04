//
//  TextModifier.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 04/11/2025.
//

import SwiftUI

struct TextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .shadow(radius: 5)
            .multilineTextAlignment(.center)
            .frame(maxHeight: .infinity)
            .padding()
    }
}

extension View {
    func customText() -> some View {
        modifier(TextModifier())
    }
}
