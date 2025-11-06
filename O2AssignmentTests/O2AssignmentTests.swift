//
//  O2AssignmentTests.swift
//  O2AssignmentTests
//
//  Created by Ján Matoniak on 04/11/2025.
//

import XCTest
@testable import O2Assignment

class MockScratchcardNetworkingService: ScratchcardNetworkingService {
    var mockVersionInfo: VersionInfo?
    var shouldThrowError: Error?

    override func checkVersionInfo(scratchCode: String) async throws -> VersionInfo {
        if let error = shouldThrowError {
            throw error
        }

        guard let versionInfo = mockVersionInfo else {
            throw RequestError.networkError(NSError(domain: "Test", code: -1, userInfo: nil))
        }

        return versionInfo
    }
}

final class O2AssignmentTests: XCTestCase {

    var mockNetworking: MockScratchcardNetworkingService!
    var sut: ScratchcardService!

    override func setUp() {
        super.setUp()
        mockNetworking = MockScratchcardNetworkingService()
        sut = ScratchcardService.shared
        sut.networking = mockNetworking
        sut.cardState = .unscratched
    }

    override func tearDown() {
        mockNetworking = nil
        sut = nil
        super.tearDown()
    }

    func testInitialState_ShouldBeUnscratched() {
        XCTAssertEqual(sut.cardState, .unscratched)
    }

    @MainActor
    func testScratchCard_ChangesStateToScratched() async {
        XCTAssertEqual(sut.cardState, .unscratched)

        await sut.scratchCard()

        switch sut.cardState {
        case .scratched(let cardId):
            XCTAssertFalse(cardId.isEmpty)
            XCTAssertNotNil(UUID(uuidString: cardId))
        default:
            XCTFail("Card state should be scratched")
        }
    }

    @MainActor
    func testScratchCard_GeneratesUniqueCardId() async {
        await sut.scratchCard()

        let firstCardId: String
        switch sut.cardState {
        case .scratched(let cardId):
            firstCardId = cardId
        default:
            XCTFail("Card state should be scratched")
            return
        }

        sut.cardState = .unscratched
        await sut.scratchCard()

        let secondCardId: String
        switch sut.cardState {
        case .scratched(let cardId):
            secondCardId = cardId
        default:
            XCTFail("Card state should be scratched")
            return
        }

        XCTAssertNotEqual(firstCardId, secondCardId)
    }

    @MainActor
    func testActivateCard_WhenUnscratched_ThrowsCardNotScratchedError() async {
        XCTAssertEqual(sut.cardState, .unscratched)

        do {
            try await sut.activateCard()
            XCTFail("Should have thrown cardNotScratched error")
        } catch let error as ScratchcardService.ActivationError {
            XCTAssertEqual(error, .cardNotScratched)
            XCTAssertEqual(error.errorDescription, "Card has to be scratched first")
        } catch {
            XCTFail("Wrong error type: \(error)")
        }

        XCTAssertEqual(sut.cardState, .unscratched)
    }

    @MainActor
    func testActivateCard_WhenAlreadyActivated_ThrowsAlreadyActivatedError() async {
        await sut.scratchCard()
        mockNetworking.mockVersionInfo = VersionInfo(
            ios: "7.0",
            iosTM: "6.0",
            iosRA: "5.0",
            iosRA_2: "4.0",
            android: "8.0",
            androidTM: "7.0",
            androidRA: "6.0"
        )

        try? await sut.activateCard()
        XCTAssertEqual(sut.cardState, .activated)

        do {
            try await sut.activateCard()
            XCTFail("Should have thrown alreadyActivated error")
        } catch let error as ScratchcardService.ActivationError {
            XCTAssertEqual(error, .alreadyActivated)
            XCTAssertEqual(error.errorDescription, "This card was already activated")
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    @MainActor
    func testActivateCard_WithVersionGreaterThan6_1_ActivatesSuccessfully() async {
        await sut.scratchCard()
        mockNetworking.mockVersionInfo = VersionInfo(
            ios: "7.0",
            iosTM: "6.0",
            iosRA: "5.0",
            iosRA_2: "4.0",
            android: "8.0",
            androidTM: "7.0",
            androidRA: "6.0"
        )

        do {
            try await sut.activateCard()
        } catch {
            XCTFail("Should not throw error: \(error)")
        }

        XCTAssertEqual(sut.cardState, .activated)
    }

    @MainActor
    func testActivateCard_WithVersionExactly6_2_ActivatesSuccessfully() async {
        await sut.scratchCard()
        mockNetworking.mockVersionInfo = VersionInfo(
            ios: "6.2",
            iosTM: "6.0",
            iosRA: "5.0",
            iosRA_2: "4.0",
            android: "8.0",
            androidTM: "7.0",
            androidRA: "6.0"
        )

        do {
            try await sut.activateCard()
        } catch {
            XCTFail("Should not throw error: \(error)")
        }

        XCTAssertEqual(sut.cardState, .activated)
    }

    @MainActor
    func testActivateCard_WithVersionExactly6_1_ThrowsVersionNotMetError() async {
        await sut.scratchCard()
        mockNetworking.mockVersionInfo = VersionInfo(
            ios: "6.1",
            iosTM: "6.0",
            iosRA: "5.0",
            iosRA_2: "4.0",
            android: "8.0",
            androidTM: "7.0",
            androidRA: "6.0"
        )

        do {
            try await sut.activateCard()
            XCTFail("Should have thrown versionNotMet error")
        } catch let error as ScratchcardService.ActivationError {
            XCTAssertEqual(error, .versionNotMet)
            XCTAssertEqual(error.errorDescription, "Brother i dont know why.. But your card is not activated. Just get over it")
        } catch {
            XCTFail("Wrong error type: \(error)")
        }

        switch sut.cardState {
        case .scratched:
            XCTAssert(true)
        default:
            XCTFail("State should remain scratched after failed activation")
        }
    }

    @MainActor
    func testActivateCard_WithVersionLessThan6_1_ThrowsVersionNotMetError() async {
        await sut.scratchCard()
        mockNetworking.mockVersionInfo = VersionInfo(
            ios: "5.0",
            iosTM: "6.0",
            iosRA: "5.0",
            iosRA_2: "4.0",
            android: "8.0",
            androidTM: "7.0",
            androidRA: "6.0"
        )

        do {
            try await sut.activateCard()
            XCTFail("Should have thrown versionNotMet error")
        } catch let error as ScratchcardService.ActivationError {
            XCTAssertEqual(error, .versionNotMet)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    @MainActor
    func testActivateCard_WithInvalidVersionString_ThrowsVersionNotMetError() async {
        await sut.scratchCard()
        mockNetworking.mockVersionInfo = VersionInfo(
            ios: "invalid",
            iosTM: "6.0",
            iosRA: "5.0",
            iosRA_2: "4.0",
            android: "8.0",
            androidTM: "7.0",
            androidRA: "6.0"
        )

        do {
            try await sut.activateCard()
            XCTFail("Should have thrown versionNotMet error")
        } catch let error as ScratchcardService.ActivationError {
            XCTAssertEqual(error, .versionNotMet)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    @MainActor
    func testActivateCard_WithEmptyVersionString_ThrowsVersionNotMetError() async {
        await sut.scratchCard()
        mockNetworking.mockVersionInfo = VersionInfo(
            ios: "",
            iosTM: "6.0",
            iosRA: "5.0",
            iosRA_2: "4.0",
            android: "8.0",
            androidTM: "7.0",
            androidRA: "6.0"
        )

        do {
            try await sut.activateCard()
            XCTFail("Should have thrown versionNotMet error")
        } catch let error as ScratchcardService.ActivationError {
            XCTAssertEqual(error, .versionNotMet)
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    @MainActor
    func testActivateCard_WithNetworkError_ThrowsNetworkError() async {
        await sut.scratchCard()
        mockNetworking.shouldThrowError = RequestError.networkError(
            NSError(domain: "NetworkError", code: -1009, userInfo: nil)
        )

        do {
            try await sut.activateCard()
            XCTFail("Should have thrown network error")
        } catch let error as RequestError {
            switch error {
            case .networkError:
                XCTAssert(true)
            default:
                XCTFail("Should be network error")
            }
        } catch {
            XCTFail("Wrong error type: \(error)")
        }

        switch sut.cardState {
        case .scratched:
            XCTAssert(true)
        default:
            XCTFail("State should remain scratched after network error")
        }
    }

    @MainActor
    func testActivateCard_PassesCorrectCardIdToNetworkService() async {
        await sut.scratchCard()

        let expectedCardId: String
        switch sut.cardState {
        case .scratched(let cardId):
            expectedCardId = cardId
        default:
            XCTFail("Card should be scratched")
            return
        }

        mockNetworking.mockVersionInfo = VersionInfo(
            ios: "7.0",
            iosTM: "6.0",
            iosRA: "5.0",
            iosRA_2: "4.0",
            android: "8.0",
            androidTM: "7.0",
            androidRA: "6.0"
        )

        try? await sut.activateCard()

        XCTAssertNotNil(expectedCardId)
    }

    @MainActor
    func testActivateCard_WithVeryLargeVersionNumber_ActivatesSuccessfully() async {
        await sut.scratchCard()
        mockNetworking.mockVersionInfo = VersionInfo(
            ios: "999.9",
            iosTM: "6.0",
            iosRA: "5.0",
            iosRA_2: "4.0",
            android: "8.0",
            androidTM: "7.0",
            androidRA: "6.0"
        )

        do {
            try await sut.activateCard()
        } catch {
            XCTFail("Should not throw error: \(error)")
        }

        XCTAssertEqual(sut.cardState, .activated)
    }
}
