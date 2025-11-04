//
//  LoadingView.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 03/11/2025.
//

import SwiftUI

struct LoadingView<Content: View>: View  {
    @Binding var isLoading: Bool

    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            content
            
            ZStack {
                Rectangle()
                    .foregroundStyle(.white.opacity(0.7))
                    .ignoresSafeArea()
                
                ProgressView()
                    .tint(.black)
                    .scaleEffect(1.5)
            }
            .opacity(isLoading ? 1 : 0)
        }
    }
}

#Preview {
    LoadingView(isLoading: .constant(false), content: {
        Text("Hello World")
    })
}
