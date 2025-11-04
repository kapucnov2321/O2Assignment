//
//  ActivationViewViewModel.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 04/11/2025.
//

import Foundation

class ActivationViewViewModel: ObservableObject {
    private var scratchCardService: ScratchcardService = .shared

    @Published var isLoading: Bool = false
    @Published var errorReason: String?

    var cardState: ScratchcardState {
        scratchCardService.cardState
    }

    func activateCard() {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                try await scratchCardService.activateCard()
            } catch {
                await MainActor.run {
                    errorReason = error.localizedDescription
                }
            }
    
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
