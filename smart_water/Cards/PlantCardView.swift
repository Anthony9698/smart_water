//
//  PlantCardView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct PlantCardView: View {
    let plant: Plant
    private var photoURL: URL? {
        guard let photoPath = plant.photoUrl else {
            return nil
        }
        
        return URL(
            string: photoPath,
            relativeTo: AppConfiguration.apiBaseURL
        )?.absoluteURL
    }
    
    var body: some View {
        HStack(spacing: 16) {
            plantImage
            
            VStack(alignment: .leading, spacing: 4) {
                Text(plant.name.capitalized)
                    .font(.headline)
                    .foregroundStyle(.black)
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundStyle(.blue)
                    LastWateredText(date: plant.lastWateredAt)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .frame(width: 350, height: 80)
        .background(Color.gray.opacity(0.1))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
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
            .frame(width: 56, height: 56)
            .clipShape(
                RoundedRectangle(cornerRadius: 10)
            )
        } else {
            placeholderImage
                .frame(width: 56, height: 56)
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
    PlantCardView(
        plant: Plant(
            id: "preview-plant",
            name: "Monstera",
            roomId: "preview-room",
            species: "Monstera deliciosa",
            moistureEntityId: nil,
            pumpEntityId: nil,
            photoUrl: nil,
            lastWateredAt: Date().addingTimeInterval(-300)
        )
    )
}
