//
//  PlantModalView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct PlantModalView: View {
    enum Mode {
        case details
        case editing
    }

    @State private var plant: Plant
    @State private var isWatering = false
    @State private var errorMessage: String?
    @State private var mode: Mode = .details

    @Environment(\.dismiss) private var dismiss
    let onWater: (String) async throws -> Plant
    let onUpdate: (
        String, // plantId
        String, // name
        String, // roomId
        String?, // species
        String?, // sensorId
        Data? // photoData
    ) async throws -> Plant

    init(
        plant: Plant,
        onWater: @escaping (
            String
        ) async throws -> Plant,
        onUpdate: @escaping (
            String, // plant ID
            String, // name
            String, // room ID
            String?, // species
            String?, // sensor ID
            Data? // new photo
        ) async throws -> Plant
    ) {
        _plant = State(initialValue: plant)
        self.onWater = onWater
        self.onUpdate = onUpdate
    }

    private var photoURL: URL? {
        guard let photoPath = plant.photoUrl else {
            return nil
        }

        return URL(
            string: photoPath,
            relativeTo: AppConfiguration.apiBaseURL
        )?.absoluteURL
    }

    @Environment(\.dismiss) var dismissModal

    var body: some View {
        NavigationStack {
            switch mode {
            case .details:
                plantDetails

            case .editing:
                EditPlantView(
                    plant: plant,
                    onCancel: {
                        mode = .details
                    },
                    onSave: {
                        name,
                        roomId,
                        species,
                        sensorId,
                        photoData in
                        plant = try await onUpdate(
                            plant.id,
                            name,
                            roomId,
                            species,
                            sensorId,
                            photoData
                        )

                        mode = .details
                    }
                )
            }
        }
    }

    @ViewBuilder
    private var plantImage: some View {
        if let photoURL {
            AsyncImage(url: photoURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()

                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()

                case .failure:
                    placeholderImage

                @unknown default:
                    placeholderImage
                }
            }
        } else {
            placeholderImage
        }
    }

    private func waterPlant() {
        Task {
            isWatering = true
            errorMessage = nil

            defer {
                isWatering = false
            }

            do {
                plant = try await onWater(plant.id)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private var plantDetails: some View {
        VStack {
            plantImage
                .frame(width: 200, height: 200)
                .background(Color.gray.opacity(0.15))
                .clipShape(
                    RoundedRectangle(cornerRadius: 16)
                )
                .clipped()

            if let species = plant.species {
                Text(species)
                    .foregroundStyle(.secondary)
            }

            Button {
                waterPlant()
            } label: {
                Text(
                    isWatering
                        ? "Watering..."
                        : "Water"
                )
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 100, height: 48)
                .background(.blue)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
                )
            }
            .disabled(isWatering)
            .buttonStyle(.plain)

            if let errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(plant.name.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(
                placement: .cancellationAction
            ) {
                Button("Close") {
                    dismiss()
                }
            }

            ToolbarItem(
                placement: .primaryAction
            ) {
                Button("Edit") {
                    mode = .editing
                }
            }
        }
    }

    private var placeholderImage: some View {
        Image(systemName: "leaf.fill")
            .resizable()
            .scaledToFit()
            .padding(14)
            .foregroundStyle(.green)
            .background(Color.green.opacity(0.1))
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
    }
}

#Preview {
    @Previewable @State
    var isShowingStandardModal = false

    let previewPlant = Plant(
        id: "preview-plant",
        name: "Monstera",
        roomId: "preview-room",
        species: "Monstera deliciosa",
        moistureEntityId: "sensor.soil_moisture_1",
        pumpEntityId: nil,
        photoUrl: nil,
        lastWateredAt: Date()
            .addingTimeInterval(-3600)
    )

    VStack {
        Text("Main Screen")

        Button("Open Modal") {
            isShowingStandardModal = true
        }
        .sheet(
            isPresented: $isShowingStandardModal
        ) {
            PlantModalView(
                plant: previewPlant,
                onWater: { plantId in
                    print(
                        "Watering preview plant:",
                        plantId
                    )

                    return Plant(
                        id: previewPlant.id,
                        name: previewPlant.name,
                        roomId: previewPlant.roomId,
                        species: previewPlant.species,
                        moistureEntityId:
                        previewPlant.moistureEntityId,
                        pumpEntityId:
                        previewPlant.pumpEntityId,
                        photoUrl: previewPlant.photoUrl,
                        lastWateredAt: Date()
                    )
                },
                onUpdate: {
                    plantId,
                    name,
                    roomId,
                    species,
                    sensorId,
                    photoData in
                    print("Updating plant:", plantId)
                    print("Name:", name)
                    print("Room ID:", roomId)
                    print("Species:", species ?? "None")
                    print(
                        "Sensor ID:",
                        sensorId ?? "None"
                    )
                    print(
                        "Photo bytes:",
                        photoData?.count ?? 0
                    )

                    return Plant(
                        id: plantId,
                        name: name,
                        roomId: roomId,
                        species: species,
                        moistureEntityId: sensorId,
                        pumpEntityId:
                        previewPlant.pumpEntityId,
                        photoUrl: previewPlant.photoUrl,
                        lastWateredAt:
                        previewPlant.lastWateredAt
                    )
                }
            )
        }
    }
}
