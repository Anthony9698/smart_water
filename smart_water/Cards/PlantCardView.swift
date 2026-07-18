//
//  PlantCardView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        HStack {
            Text(plant.name.capitalized)
                .foregroundStyle(Color.black)
            Spacer()
        }
        .padding(24)
        .background(Color(.gray).opacity(0.1))
        .frame(width: 350, height: 65)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    PlantCardView(
        plant: Plant(
            id: "preview-plant",
            name: "Monstera",
            roomId: "preview-room",
            species: "Monstera deliciosa",
            moistureEntityId: nil,
            pumpEntityId: nil,
            photoUrl: nil
        )
    )
}
