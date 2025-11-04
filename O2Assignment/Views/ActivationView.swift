//
//  ActivationView.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 03/11/2025.
//

import SwiftUI

struct ActivationView: View {
    @StateObject var viewModel: ActivationViewViewModel = .init()

    var body: some View {
        BackgroundView {
            LoadingView(isLoading: $viewModel.isLoading) {
                VStack {
                    Text("🎉 Activate the card!")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                        .padding()
                    
                    switch viewModel.cardState {
                    case .unscratched:
                        Text("Card has to be scratched first. Visit scratch screen")
                            .customText()
                    case .scratched:
                        PrimaryButton(title: "Activate by tapping here!", color: .accentColor) {
                            viewModel.activateCard()
                        }
                        .padding()
                        .frame(maxHeight: .infinity)
                    case .activated:
                        Text("The card was scratched & activated. Restart app to try again")
                            .customText()
                    }
                }
            }
        }
        .alert(item: $viewModel.errorReason) { reason in
            Alert(title: Text("Error"), message: Text(reason), dismissButton: .cancel())
        }
    }
}

#Preview {
    ActivationView()
}
