//
//  RoomView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct RoomView: View {
    let room: Room

    @State private var isShowingAddPlant = false
    @State private var selectedPlant: Plant?

    @StateObject private var viewModel = PlantsViewModel(
        api: SmartWaterAPI()
    )

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            ScrollView {
                if viewModel.isLoading &&
                    viewModel.plants.isEmpty
                {
                    ProgressView("Loading plants...")
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.plants) { plant in
                            Button {
                                selectedPlant = plant
                            } label: {
                                PlantCardView(
                                    plant: plant
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .scrollBounceBehavior(.always)
            .refreshable {
                await viewModel.loadPlants(
                    roomId: room.id,
                    showLoadingIndicator: false
                )
            }
        }
        .task(id: room.id) {
            await viewModel.loadPlants(
                roomId: room.id,
                showLoadingIndicator: true
            )
        }
        .navigationTitle(
            "\(room.name) Plants".capitalized
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(
                placement: .cancellationAction
            ) {
                Button("Back") {
                    dismiss()
                }
            }

            ToolbarItem(
                placement: .primaryAction
            ) {
                Button {
                    isShowingAddPlant = true
                } label: {
                    Label(
                        "Add Plant",
                        systemImage: "plus"
                    )
                }
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 32)
        .background(Color.white)
        .sheet(isPresented: $isShowingAddPlant) {
            AddPlantView(room: room) {
                name,
                species,
                selectedSensorId,
                photoData in
                try await viewModel.createPlant(
                    name: name,
                    roomId: room.id,
                    species: species,
                    moistureEntityId:
                    selectedSensorId,
                    photoData: photoData
                )
            }
        }
        .sheet(item: $selectedPlant) { plant in
            PlantModalView(
                plant: plant,
                onWater: { plantId in
                    try await viewModel.waterPlant(
                        plantId: plantId
                    )
                },
                onUpdate: {
                    plantId,
                    name,
                    roomId,
                    species,
                    sensorId,
                    photoData in
                    try await viewModel.updatePlant(
                        plantId: plantId,
                        name: name,
                        roomId: roomId,
                        species: species,
                        moistureEntityId: sensorId,
                        photoData: photoData,
                        currentRoomId: room.id
                    )
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    let kitchen = Room(
        id: "preview-room",
        name: "Kitchen",
        plantCount: 1
    )

    NavigationStack {
        RoomView(
            room: kitchen
        )
    }
}
