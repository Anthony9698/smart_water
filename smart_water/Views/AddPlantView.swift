//
//  AddPlantView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import SwiftUI

struct AddPlantView: View {
    let room: Room
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var species = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    let onSave: (String, String?) async throws -> Void

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

    private func save() {
        guard canSave else {
            return
        }

        Task {
            isSaving = true
            errorMessage = nil

            do {
                try await onSave(trimmedName, trimmedSpecies)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                isSaving = false
            }
        }
    }
}

#Preview {
    AddPlantView(room: Room(id: "123", name: "Kitchen", plantCount: 0)) { name, species in
        print("Create plant:", name)
        print("Species:", species ?? "None")
    }
}
