//
//  AddRoomView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import SwiftUI

struct AddRoomView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var isSaving = false
    @State private var errorMessage: String?
    
    let onSave: (String) async throws -> Void

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSave: Bool {
        !trimmedName.isEmpty && !isSaving
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Room info") {
                    TextField("Room name", text: $name)
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
            .navigationTitle("Add Room")
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
                    try await onSave(trimmedName)
                    dismiss()
                } catch {
                    errorMessage = error.localizedDescription
                    isSaving = false
                }
            }
        }
}

#Preview {
    AddRoomView { name in
        print("Create room:", name)
    }
}
