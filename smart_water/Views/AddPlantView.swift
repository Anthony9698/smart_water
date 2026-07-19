//
//  AddPlantView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import PhotosUI
import SwiftUI
import UIKit

struct AddPlantView: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var species = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var photoErrorMessage: String?

    let onSave: (String, String?, Data?) async throws -> Void

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedSpecies: String {
        species.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && !isSaving
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photo") {
                    if let photoData,
                       let image = UIImage(data: photoData)
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
                    }

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {
                        Label(
                            photoData == nil ? "Choose Photo" : "Change Photo",
                            systemImage: "photo"
                        )
                    }

                    if photoData != nil {
                        Button("Remove Photo", role: .destructive) {
                            selectedPhoto = nil
                            photoData = nil
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
                    TextField("Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit {
                            save()
                        }
                }
                Section("Species") {
                    TextField("Species", text: $species)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit {
                            save()
                        }
                }
                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Add \(room.name) Plant".capitalized)
            .navigationBarTitleDisplayMode(.inline)
            .disabled(isSaving)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
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
    }

    private func loadPhoto(
        _ item: PhotosPickerItem?
    ) async {
        photoErrorMessage = nil

        guard let item else {
            photoData = nil
            return
        }

        do {
            guard let originalData = try await item.loadTransferable(
                type: Data.self
            ) else {
                photoErrorMessage = "The selected photo could not be loaded."
                return
            }

            guard let image = UIImage(data: originalData) else {
                photoErrorMessage = "The selected file is not a valid image."
                return
            }

            guard let jpegData = image.jpegData(
                compressionQuality: 0.85
            ) else {
                photoErrorMessage = "The photo could not be converted."
                return
            }

            photoData = jpegData
        } catch {
            photoErrorMessage = error.localizedDescription
            photoData = nil
        }
    }

    private func save() {
        guard canSave else {
            return
        }

        let optionalSpecies = trimmedSpecies.isEmpty
            ? nil
            : trimmedSpecies

        Task {
            isSaving = true
            errorMessage = nil

            do {
                try await onSave(
                    trimmedName,
                    optionalSpecies,
                    photoData
                )

                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}

#Preview {
    AddPlantView(
        room: Room(
            id: "123",
            name: "Kitchen",
            plantCount: 0
        )
    ) { name, species, photoData in
        print("Create plant:", name)
        print("Species:", species ?? "None")
        print("Photo bytes:", photoData?.count ?? 0)
    }
}
