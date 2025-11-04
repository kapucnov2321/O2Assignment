//
//  ScratchcardService.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 03/11/2025.
//

import Foundation

enum ScratchcardState: Equatable {
    case unscratched
    case scratched(cardId: String)
    case activated
    
    var readableDescription: String {
        switch self {
        case .scratched:
            "Scratched"
        case .unscratched:
            "Unscratched"
        case .activated:
            "Activated"
        }
    }
}

class ScratchcardService: ObservableObject {
    @Published var cardState: ScratchcardState = .unscratched

    private let networking: ScratchcardNetworkingService = .init()
    static let shared = ScratchcardService()

    enum ActivationError: LocalizedError {
        case cardNotScratched
        case versionNotMet
        case alreadyActivated
        
        var errorDescription: String? {
            switch self {
            case .cardNotScratched:
                "Card has to be scratched first"
            case .versionNotMet:
                "Brother i dont know why.. But your card is not activated. Just get over it"
            case .alreadyActivated:
                "This card was already activated"
            }
        }
    }

    func scratchCard() async {
        do {
            try await Task.sleep(for: .seconds(2))
            
            await MainActor.run {
                cardState = .scratched(cardId: UUID().uuidString)
            }
        } catch {}
    }
    
    func activateCard() async throws {
        switch cardState {
        case .unscratched:
            throw ActivationError.cardNotScratched
        case .scratched(let cardId):
            let response = try await networking.checkVersionInfo(scratchCode: cardId)
            let iosVersion = Double(response.ios) ?? 0
            
            if iosVersion > 6.1 {
                await MainActor.run {
                    cardState = .activated
                }
            } else {
                throw ActivationError.versionNotMet
            }
        case .activated:
            throw ActivationError.alreadyActivated
        }
    }
    
    private init() {}
}
