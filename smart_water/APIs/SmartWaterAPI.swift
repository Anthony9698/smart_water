//
//  SmartWaterAPI.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import Foundation

enum APIError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
}

struct SmartWaterAPI {
    let baseURL: URL

    func getRooms() async throws -> [Room] {
        let url = baseURL
            .appendingPathComponent("api")
            .appendingPathComponent("rooms")

        return try await get(url: url)
    }

    private func get<Response: Decodable>(
        url: URL
    ) async throws -> Response {
        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        return try decoder.decode(Response.self, from: data)
    }
}
