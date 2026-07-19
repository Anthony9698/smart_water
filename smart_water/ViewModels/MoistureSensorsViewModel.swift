//
//  MoistureSensorsViewModel.swift
//  smart_water
//
//  Created by Anthony Viera on 7/19/26.
//

import Combine
import Foundation

@MainActor
final class MoistureSensorsViewModel: ObservableObject {
    @Published private(set) var sensors: [MoistureSensor] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let api: SmartWaterAPI

    init(api: SmartWaterAPI) {
        self.api = api
    }

    func loadSensors() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            sensors = try await api.getMoistureSensors()
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to load moisture sensors:", error)
        }
    }
}
