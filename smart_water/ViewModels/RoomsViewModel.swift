//
//  RoomsViewModel.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import Foundation
import Combine

@MainActor
final class RoomsViewModel: ObservableObject {
    @Published private(set) var rooms: [Room] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let api: SmartWaterAPI

    init(api: SmartWaterAPI) {
        self.api = api
    }

    func loadRooms() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            rooms = try await api.getRooms()
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to load rooms:", error)
        }
    }
}
