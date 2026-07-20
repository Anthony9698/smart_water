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
        moistureEntityId: String? = nil,
        photoData: Data? = nil
    ) async throws {
        var plant = try await api.createPlant(
            name: name,
            roomId: roomId,
            species: species,
            moistureEntityId: moistureEntityId
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

    @discardableResult
    func updatePlant(
        plantId: String,
        name: String,
        roomId: String,
        species: String?,
        moistureEntityId: String?,
        photoData: Data?,
        currentRoomId: String
    ) async throws -> Plant {
        var updatedPlant = try await api.updatePlant(
            plantId: plantId,
            name: name,
            roomId: roomId,
            species: species,
            moistureEntityId: moistureEntityId
        )

        if let photoData {
            updatedPlant = try await api.uploadPlantPhoto(
                plantId: plantId,
                photoData: photoData
            )
        }

        if let index = plants.firstIndex(
            where: { $0.id == plantId }
        ) {
            if updatedPlant.roomId == currentRoomId {
                plants[index] = updatedPlant
            } else {
                // The plant was moved to another room.
                plants.remove(at: index)
            }
        }

        return updatedPlant
    }

    @discardableResult
    func waterPlant(
        plantId: String
    ) async throws -> Plant {
        let updatedPlant = try await api.createWaterPlant(
            plantId: plantId
        )

        if let index = plants.firstIndex(
            where: { $0.id == plantId }
        ) {
            plants[index] = updatedPlant
        }

        return updatedPlant
    }

    func loadPlants(
        roomId: String,
        showLoadingIndicator: Bool = true
    ) async {
        print("loadPlants called for:", roomId)

        if showLoadingIndicator {
            isLoading = true
            errorMessage = nil
        }

        defer {
            if showLoadingIndicator {
                isLoading = false
            }
        }

        do {
            let loadedPlants = try await api.getPlants(
                roomId: roomId
            )

            print(
                "Received plants:",
                loadedPlants.map {
                    ($0.name, $0.lastWateredAt as Any)
                }
            )

            plants = loadedPlants
            errorMessage = nil
        } catch is CancellationError {
            print(
                "Plant task cancelled:",
                Task.isCancelled
            )
        } catch let error as URLError
            where error.code == .cancelled
        {
            print(
                "Plant URL request cancelled:",
                Task.isCancelled
            )
        } catch {
            errorMessage = error.localizedDescription
            print("Failed to load plants:", error)
        }
    }
}
