//
//  ScratchScreen.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 03/11/2025.
//

import SwiftUI

struct ScratchView: View {
    @StateObject private var viewModel: ScratchViewViewModel = .init()

    var body: some View {
        BackgroundView {
            LoadingView(isLoading: $viewModel.isLoading) {
                    VStack {
                        Text("🎉 Scratch the card!")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .padding()
                        
                        switch viewModel.cardState {
                        case .unscratched:
                            VStack {
                                Text("Press button below !")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 80)
                                    .background {
                                        RoundedRectangle(cornerRadius: 20)
                                            .foregroundStyle(.white.opacity(0.8))
                                        
                                    }
                                    .frame(maxHeight: .infinity)
                                
                                
                                PrimaryButton(title: "Just tap here !", color: .accentColor) {
                                    viewModel.triggerUncancellableScratching()
                                }
                            }
                        case .scratched:
                            Text("The card was already scratched. Please activate it")
                                .customText()
                        case .activated:
                            Text("The card was scratched & activated. Restart app to try again")
                                .customText()
                        }
                    }
                    .task(id: viewModel.shouldScratchCard) {
                        guard viewModel.shouldScratchCard else {
                            return
                        }

                        await viewModel.scratchCard()
                    }
                    .padding()
                }
            }
        }
}

#Preview {
    ScratchView()
}
