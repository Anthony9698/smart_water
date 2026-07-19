//
//  PlantModalView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct PlantModalView: View {
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

                Button(action: {}) {
                    Text("water".capitalized)
                        .foregroundStyle(Color.white)
                        .frame(width: 100, height: 48)
                        .fontWeight(.bold)
                }
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
    VStack {
        Text("Main Screen")
        Button(action: { isShowingStandardModal = true }) {
            Text("Open Modal")
        }
        .sheet(isPresented: $isShowingStandardModal) {
            PlantModalView(
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
    }
}
