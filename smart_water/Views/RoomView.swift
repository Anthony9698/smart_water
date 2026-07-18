//
//  RoomView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

import SwiftUI

struct RoomView: View {
    let room: String
    let plantCount: Int

    @Environment(\.dismiss) private var dismiss

    @State private var selectedPlant: Plant?

    let plants = [
        Plant(name: "Monstera 1", lastWatered: "Yesterday"),
        Plant(name: "Monstera 2", lastWatered: "2 days ago")
    ]

    var body: some View {
        VStack {
            header

            HStack {
                Text("Plants")
                    .font(.headline)

                Spacer()
            }
            .padding(24)

            VStack(spacing: 12) {
                ForEach(plants) { plant in
                    Button {
                        selectedPlant = plant
                    } label: {
                        PlantCardView(
                            name: plant.name,
                            lastWatered: plant.lastWatered
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)

            Spacer()
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
        .sheet(item: $selectedPlant) { plant in
            PlantModalView(
                name: plant.name,
                pictureUrl: "https://placehold.co/200x200/dddddd/999999/png"
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrowshape.backward.fill")
                    Text(room)
                }
                .foregroundStyle(.black)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }
}

struct Plant: Identifiable {
    let id = UUID()
    let name: String
    let lastWatered: String
}

#Preview {
    NavigationStack {
        RoomView(room: "Kitchen", plantCount: 0)
    }
}
