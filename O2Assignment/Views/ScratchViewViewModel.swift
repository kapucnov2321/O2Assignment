//
//  ScratchViewViewModel.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 04/11/2025.
//

import Foundation

class ScratchViewViewModel: ObservableObject {
    private var scratchCardService: ScratchcardService = .shared
    
    @Published private(set) var shouldScratchCard: Bool = false
    @Published var isLoading: Bool = false
    
    var cardState: ScratchcardState {
        scratchCardService.cardState
    }

    func triggerUncancellableScratching() {
        shouldScratchCard = true
    }
    
    func scratchCard() async {
        await MainActor.run {
            isLoading = true
        }

        await scratchCardService.scratchCard()
        
        await MainActor.run {
            isLoading = false
        }
    }
}
