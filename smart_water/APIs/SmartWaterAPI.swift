//
//  SmartWaterAPI.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import Foundation

enum AppConfiguration {
    static let apiBaseURL = URL(
        string: "http://192.168.68.64:8000"
    )!
}

enum APIError: Error {
    case invalidResponse
    case httpError(statusCode: Int)
}

struct SmartWaterAPI {
    let baseURL: URL

    init(
        baseURL: URL = AppConfiguration.apiBaseURL
    ) {
        self.baseURL = baseURL
    }

    func getRooms() async throws -> [Room] {
        try await get(path: "api/rooms")
    }

    func getPlants(roomId: String) async throws -> [Plant] {
        try await get(
            path: "api/plants",
            queryItems: [
                URLQueryItem(
                    name: "room_id",
                    value: roomId
                ),
            ]
        )
    }

    func getMoistureSensors() async throws -> [MoistureSensor] {
        try await get(path: "api/ha/moisture-sensors")
    }

    func createRoom(name: String) async throws -> Room {
        let payload = CreateRoomRequest(name: name)

        return try await post(
            path: "api/rooms",
            body: payload
        )
    }

    func createPlant(
        name: String,
        roomId: String,
        species: String? = nil,
        moistureEntityId: String? = nil
    ) async throws -> Plant {
        let payload = CreatePlantRequest(
            name: name,
            roomId: roomId,
            species: species,
            moistureEntityId: moistureEntityId
        )

        return try await post(path: "api/plants", body: payload)
    }

    func createWaterPlant(plantId: String) async throws -> Plant {
        let url = makeURL(
            path: "api/plants/\(plantId)/watered"
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        return try await send(request)
    }

    func uploadPlantPhoto(
        plantId: String,
        photoData: Data
    ) async throws -> Plant {
        let url = makeURL(
            path: "api/plants/\(plantId)/photo"
        )

        let boundary = UUID().uuidString

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()

        body.append(
            Data("--\(boundary)\r\n".utf8)
        )

        body.append(
            Data(
                """
                Content-Disposition: form-data; name="photo"; filename="plant.jpg"\r
                Content-Type: image/jpeg\r
                \r

                """.utf8
            )
        )

        body.append(photoData)

        body.append(
            Data("\r\n--\(boundary)--\r\n".utf8)
        )

        request.httpBody = body

        return try await send(request)
    }

    private func get<Response: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = []
    ) async throws -> Response {
        let basePathURL = makeURL(path: path)

        guard var components = URLComponents(
            url: basePathURL,
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidResponse
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidResponse
        }

        let request = URLRequest(url: url)

        return try await send(request)
    }

    private func post<Body: Encodable, Response: Decodable>(
        path: String,
        body: Body
    ) async throws -> Response {
        let url = makeURL(path: path)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        request.httpBody = try encoder.encode(body)

        return try await send(request)
    }

    private func send<Response: Decodable>(
        _ request: URLRequest
    ) async throws -> Response {
        let (data, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard 200 ..< 300 ~= httpResponse.statusCode else {
            throw APIError.httpError(
                statusCode: httpResponse.statusCode
            )
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode(Response.self, from: data)
    }

    private func makeURL(path: String) -> URL {
        path
            .split(separator: "/")
            .reduce(baseURL) { url, component in
                url.appendingPathComponent(String(component))
            }
    }
}
