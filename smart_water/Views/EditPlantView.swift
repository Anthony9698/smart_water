//
//  EditPlantView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/19/26.
//

import PhotosUI
import SwiftUI
import UIKit

struct EditPlantView: View {
    let plant: Plant
    let onCancel: () -> Void = {}
    let onSave: (
        String, // name
        String, // room ID
        String?, // species
        String?, // moisture sensor ID
        Data? // new photo
    ) async throws -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var isSaving = false
    @State private var errorMessage: String?

    @State private var name: String
    @State private var selectedRoomId: String
    @State private var species: String
    @State private var selectedSensorId: String?

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var newPhotoData: Data?
    @State private var photoErrorMessage: String?

    @StateObject private var sensorsViewModel =
        MoistureSensorsViewModel(
            api: SmartWaterAPI()
        )

    @StateObject private var roomsViewModel =
        RoomsViewModel(
            api: SmartWaterAPI()
        )

    init(
        plant: Plant,
        onCancel _: @escaping () -> Void = {},
        onSave: @escaping (
            String,
            String,
            String?,
            String?,
            Data?
        ) async throws -> Void
    ) {
        self.plant = plant
        self.onSave = onSave

        _name = State(initialValue: plant.name)
        _selectedRoomId = State(
            initialValue: plant.roomId
        )
        _species = State(initialValue: plant.species ?? "")
        _selectedSensorId = State(
            initialValue: plant.moistureEntityId
        )
    }

    var body: some View {
        Form {
            Section("Photo") {
                // Show the newly selected photo first.
                if let newPhotoData,
                   let image = UIImage(data: newPhotoData)
                {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 220)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                        .clipped()

                    // Otherwise, show the existing backend photo.
                } else if let existingPhotoURL {
                    AsyncImage(url: existingPhotoURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)

                        case let .success(image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 220)
                                .clipped()

                        case .failure:
                            photoPlaceholder

                        @unknown default:
                            photoPlaceholder
                        }
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 12)
                    )

                    // No existing or newly selected photo.
                } else {
                    photoPlaceholder
                }

                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images
                ) {
                    Label(
                        plant.photoUrl == nil && newPhotoData == nil
                            ? "Choose Photo"
                            : "Replace Photo",
                        systemImage: "photo"
                    )
                }

                if newPhotoData != nil {
                    Button("Discard New Photo", role: .destructive) {
                        selectedPhoto = nil
                        newPhotoData = nil
                        photoErrorMessage = nil
                    }
                }

                if let photoErrorMessage {
                    Text(photoErrorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .onChange(of: selectedPhoto) { _, newPhoto in
                Task {
                    await loadPhoto(newPhoto)
                }
            }
            Section("Name") {
                TextField(
                    "Name",
                    text: $name
                )
                .textInputAutocapitalization(.words)
            }
            Section("Room") {
                if roomsViewModel.isLoading &&
                    roomsViewModel.rooms.isEmpty
                {
                    ProgressView("Loading rooms...")
                } else {
                    Picker(
                        "Room",
                        selection: $selectedRoomId
                    ) {
                        ForEach(roomsViewModel.rooms) { room in
                            Text(room.name)
                                .tag(room.id)
                        }
                    }
                }

                if let message = roomsViewModel.errorMessage {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            Section("Species") {
                TextField(
                    "Species",
                    text: $species
                )
                .textInputAutocapitalization(.words)
            }

            Section("Moisture Sensor") {
                if sensorsViewModel.isLoading &&
                    sensorsViewModel.sensors.isEmpty
                {
                    ProgressView("Loading sensors...")
                } else {
                    Picker(
                        "Sensor",
                        selection: $selectedSensorId
                    ) {
                        Text("No Sensor")
                            .tag(nil as String?)

                        ForEach(
                            sensorsViewModel.sensors
                        ) { sensor in
                            Text(sensor.name)
                                .tag(
                                    sensor.entityId as String?
                                )
                        }
                    }
                }

                if let message =
                    sensorsViewModel.errorMessage
                {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            if let errorMessage {
                Section {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Edit Plant")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(isSaving)
        .task {
            await sensorsViewModel.loadSensors()
            await roomsViewModel.loadRooms()
        }
        .toolbar {
            ToolbarItem(
                placement: .cancellationAction
            ) {
                Button("Cancel") {
                    onCancel()
                }
            }

            ToolbarItem(
                placement: .confirmationAction
            ) {
                Button(isSaving ? "Saving..." : "Save") {
                    save()
                }
                .disabled(!canSave)
            }
        }
        .overlay {
            if isSaving {
                ProgressView()
            }
        }
    }

    private var existingPhotoURL: URL? {
        guard let photoPath = plant.photoUrl else {
            return nil
        }

        return URL(
            string: photoPath,
            relativeTo: AppConfiguration.apiBaseURL
        )?.absoluteURL
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedSpecies: String {
        species.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var optionalSpecies: String? {
        trimmedSpecies.isEmpty
            ? nil
            : trimmedSpecies
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && !isSaving
    }

    private func save() {
        guard canSave else {
            return
        }

        Task {
            isSaving = true
            errorMessage = nil

            do {
                try await onSave(
                    trimmedName,
                    selectedRoomId,
                    optionalSpecies,
                    selectedSensorId,
                    newPhotoData
                )

                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
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

    private var photoPlaceholder: some View {
        Image(systemName: "leaf.fill")
            .resizable()
            .scaledToFit()
            .padding(60)
            .frame(maxWidth: .infinity)
            .frame(height: 220)
            .foregroundStyle(.green)
            .background(Color.green.opacity(0.1))
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
    }

    private func loadPhoto(
        _ item: PhotosPickerItem?
    ) async {
        photoErrorMessage = nil

        guard let item else {
            newPhotoData = nil
            return
        }

        do {
            guard let originalData =
                try await item.loadTransferable(
                    type: Data.self
                )
            else {
                photoErrorMessage =
                    "The selected photo could not be loaded."
                return
            }

            guard let image = UIImage(
                data: originalData
            ) else {
                photoErrorMessage =
                    "The selected file is not a valid image."
                return
            }

            guard let jpegData = image.jpegData(
                compressionQuality: 0.85
            ) else {
                photoErrorMessage =
                    "The photo could not be converted."
                return
            }

            newPhotoData = jpegData
        } catch {
            photoErrorMessage = error.localizedDescription
            newPhotoData = nil
        }
    }
}

#Preview {
    let kitchen = Room(
        id: "kitchen-room",
        name: "Kitchen",
        plantCount: 1
    )

    let livingRoom = Room(
        id: "living-room",
        name: "Living Room",
        plantCount: 2
    )

    let office = Room(
        id: "office-room",
        name: "Office",
        plantCount: 0
    )

    let previewPlant = Plant(
        id: "preview-plant",
        name: "Monstera",
        roomId: kitchen.id,
        species: "Monstera deliciosa",
        moistureEntityId:
        "sensor.gw2000b_soil_moisture_1",
        pumpEntityId: nil,
        photoUrl: nil,
        lastWateredAt: Date()
            .addingTimeInterval(-3600)
    )

    NavigationStack {
        EditPlantView(
            plant: previewPlant
        ) {
            name,
            roomId,
            species,
            moistureEntityId,
            photoData in
            print("Name:", name)
            print("Room ID:", roomId)
            print("Species:", species ?? "None")
            print(
                "Moisture sensor:",
                moistureEntityId ?? "None"
            )
            print(
                "New photo bytes:",
                photoData?.count ?? 0
            )
        }
    }
}
