//
//  BackgroundView.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 03/11/2025.
//

import SwiftUI

struct BackgroundView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.gray.opacity(0.8), .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            content
        }
    }
}

#Preview {
    BackgroundView(content: {
        Text("Hello World!")
    })
}
