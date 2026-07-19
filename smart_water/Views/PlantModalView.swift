//
//  PlantModalView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct PlantModalView: View {
    @State private var plant: Plant
    @State private var isWatering = false
    @State private var errorMessage: String?

    let onWater: (String) async throws -> Plant

    init(
        plant: Plant,
        onWater: @escaping (String) async throws -> Plant
    ) {
        _plant = State(initialValue: plant)
        self.onWater = onWater
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
        VStack {
            HStack {
                Text(plant.name.capitalized)
                    .foregroundStyle(Color.black)
                    .padding(24)
                Spacer()
                Button(action: { dismissModal() }) {
                    Image(systemName: "xmark")
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.black)
                }
            }

            VStack(alignment: .center) {
                plantImage
                    .frame(width: 200, height: 200)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .clipped()

                Button {
                    Task {
                        isWatering = true
                        errorMessage = nil

                        do {
                            plant = try await onWater(plant.id)
                        } catch {
                            errorMessage = error.localizedDescription
                        }

                        isWatering = false
                    }
                } label: {
                    Text(isWatering ? "Watering..." : "Water")
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
            }
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        Spacer()
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
    @Previewable @State var isShowingStandardModal = false

    let previewPlant = Plant(
        id: "preview-plant",
        name: "Monstera",
        roomId: "preview-room",
        species: "Monstera deliciosa",
        moistureEntityId: "sensor.soil_moisture_1",
        pumpEntityId: nil,
        photoUrl: nil,
        lastWateredAt: Date().addingTimeInterval(-3600)
    )
    VStack {
        Text("Main Screen")
        Button(action: { isShowingStandardModal = true }) {
            Text("Open Modal")
        }
        .sheet(isPresented: $isShowingStandardModal) {
            PlantModalView(
                plant: previewPlant,
                onWater: { plantId in
                    print("Watering preview plant:", plantId)

                    return Plant(
                        id: previewPlant.id,
                        name: previewPlant.name,
                        roomId: previewPlant.roomId,
                        species: previewPlant.species,
                        moistureEntityId: previewPlant.moistureEntityId,
                        pumpEntityId: previewPlant.pumpEntityId,
                        photoUrl: previewPlant.photoUrl,
                        lastWateredAt: Date()
                    )
                }
            )
        }
    }
}
