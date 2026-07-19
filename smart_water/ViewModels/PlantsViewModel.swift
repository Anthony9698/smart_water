//
//  PlantsViewModel.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import Combine
import Foundation

@MainActor
final class PlantsViewModel: ObservableObject {
    @Published private(set) var plants: [Plant] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let api: SmartWaterAPI

    init(api: SmartWaterAPI) {
        self.api = api
    }

    func createPlant(
        name: String,
        roomId: String,
        species: String? = nil,
        photoData: Data? = nil
    ) async throws {
        var plant = try await api.createPlant(
            name: name,
            roomId: roomId,
            species: species
        )

        if let photoData {
            do {
                plant = try await api.uploadPlantPhoto(
                    plantId: plant.id,
                    photoData: photoData
                )
            } catch {
                errorMessage = """
                The plant was created, but its photo could not be uploaded.
                """

                print("Photo upload failed:", error)
            }
        }

        plants.append(plant)
    }

    func loadPlants(roomId: String) async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
        }

        do {
            plants = try await api.getPlants(roomId: roomId)
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to load plants:", error)
        }
    }
}
