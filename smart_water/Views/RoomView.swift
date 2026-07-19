//
//  RoomView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct RoomView: View {
    let room: Room
    @State private var relativeTimeReference = Date()
    @State private var isShowingAddPlant = false
    @StateObject private var viewModel = PlantsViewModel(
        api: SmartWaterAPI()
    )

    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlant: Plant?

    var body: some View {
        VStack {
            ScrollView {
                if viewModel.isLoading && viewModel.plants.isEmpty {
                    ProgressView("Loading plants...")
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.plants) { plant in
                            Button {
                                selectedPlant = plant
                            } label: {
                                PlantCardView(
                                    plant: plant,
                                    relativeTo: relativeTimeReference
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
                print("Pull-to-refresh started")

                await viewModel.loadPlants(
                    roomId: room.id,
                    showLoadingIndicator: false
                )

                print("Pull-to-refresh completed")
                relativeTimeReference = Date()
            }
            .sheet(item: $selectedPlant) { plant in
                PlantModalView(
                    plant: plant
                ) { plantId in
                    let updatedPlant = try await viewModel.waterPlant(
                        plantId: plantId
                    )

                    relativeTimeReference = Date()

                    return updatedPlant
                }
            }
        }
        .task(id: room.id) {
            await viewModel.loadPlants(
                roomId: room.id,
                showLoadingIndicator: true
            )
        }
        .navigationTitle("\(room.name) Plants".capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isShowingAddPlant = true
                } label: {
                    Label("Add Plant", systemImage: "plus")
                }
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 32)
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selectedPlant) { plant in
            PlantModalView(
                plant: plant
            ) { plantId in
                try await viewModel.waterPlant(
                    plantId: plantId
                )
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    NavigationStack {
        RoomView(
            room: Room(
                id: "preview-room",
                name: "Kitchen",
                plantCount: 0
            )
        )
    }
}
