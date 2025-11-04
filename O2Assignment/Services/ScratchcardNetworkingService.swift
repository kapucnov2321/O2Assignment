//
//  ScratchcardNetworkingService.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 04/11/2025.
//

import Foundation

enum ScratchcardEndpoint: NetworkEndpoint {
    case version(code: String)
    
    var baseUrl: String {
        return "https://api.o2.sk/"
    }
    
    var endpointUrl: String {
        switch self {
        case .version:
            "version"
        }
    }
    
    var httpMethod: HttpMethod {
        switch self {
        case .version:
            .GET
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .version(let code):
            return ["code": code]
        }
    }
}


class ScratchcardNetworkingService: NetworkingService<ScratchcardEndpoint> {
    func checkVersionInfo(scratchCode: String) async throws -> VersionInfo {
        try await makeRequest(endpoint: .version(code: scratchCode), for: VersionInfo.self)
    }
}
