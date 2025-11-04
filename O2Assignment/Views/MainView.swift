//
//  ContentView.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 03/11/2025.
//

import SwiftUI

enum NavigationDestination: Hashable {
    case activationView
    case scratchView
}

struct MainView: View {
    @State private var path = NavigationPath()

    @ObservedObject private var scratchCardService: ScratchcardService = .shared

    var body: some View {
        NavigationStack(path: $path) {
            BackgroundView {
                VStack {
                    VStack(spacing: 8) {
                        Text("Scratch Card Status")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(scratchCardService.cardState.readableDescription.capitalized)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
    
                    Spacer()
    
                    VStack(spacing: 20) {
                        NavigationButton(
                            title: "🎟 Scratch Screen",
                            color: .green
                        ) {
                            path.append(NavigationDestination.scratchView)
                        }
                        
                        NavigationButton(
                            title: "🔑 Activation Screen",
                            color: .orange
                        ) {
                            path.append(NavigationDestination.activationView)
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .activationView:
                    ActivationView()
                case .scratchView:
                    ScratchView()
                }
            }
        }
    }
}



#Preview {
    MainView()
}
