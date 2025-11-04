//
//  NetworkingService.swift
//  O2Assignment
//
//  Created by Ján Matoniak on 04/11/2025.
//

import Foundation

protocol NetworkEndpoint {
    var baseUrl: String { get }
    var endpointUrl: String { get }
    var httpMethod: HttpMethod { get }
    var parameters: [String: Any] { get }
}

enum HttpMethod {
    case GET
    case POST
    case PUT
}

enum RequestError: LocalizedError {
    case urlNotValid
    case networkError(Error)
    case decodingError(Error)
}

class NetworkingService<E: NetworkEndpoint> {
    func makeRequest<T: Codable>(endpoint: E, for model: T.Type) async throws -> T {
        guard var urlComponents = URLComponents(string: endpoint.baseUrl + endpoint.endpointUrl) else {
            throw RequestError.urlNotValid
        }

        urlComponents.queryItems = endpoint.parameters.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }

        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            do {
                print("--- HTTP RESPONSE START ---")
                print(String(data: data, encoding: .utf8) ?? "EMPTY RESPONSE")
                print("--- HTTP RESPONSE END ---")

                let decodedClass = try JSONDecoder().decode(T.self, from: data)
                return decodedClass
            } catch {
                throw RequestError.decodingError(error)
            }
        } catch {
            throw RequestError.networkError(error)
        }
    }
}
