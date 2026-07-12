//
//  PlantView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct PlantView: View {
    let name: String
    let pictureUrl: String
    let lastWateredActivity = [
        LastWateredActivity(lastWatered: "Today", timeWateredSeconds: 3),
        LastWateredActivity(lastWatered: "Today", timeWateredSeconds: 3)
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .firstTextBaseline) {
                Text(name)
                    .foregroundStyle(Color.black)
                    .padding(24)
                Spacer()
            }

            VStack(alignment: .center) {
                AsyncImage(url: URL(string: pictureUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()

                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()

                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.gray)
                            .padding(50)

                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 200, height: 200)
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(width: 200, height: 200)
                .clipped()
                
                Button(action: {}) {
                    Text("WATER")
                        .frame(width: 100, height: 25)

                }
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            VStack(alignment: .leading) {
                Text("Recent Water Activity")
                    .foregroundStyle(Color.black)
                VStack(spacing: 0) {
                    ForEach(lastWateredActivity, id: \.id) { activity in
                        LastWateredCardView(lastWatered: activity.lastWatered, timeWateredSeconds: activity.timeWateredSeconds)
                    }
                }
            }
        }
        .background(Color.white)
    }
}

struct LastWateredActivity: Identifiable {
    let id = UUID()
    let lastWatered: String
    let timeWateredSeconds: Int
}

#Preview {
    PlantView(name: "Monstera", pictureUrl: "https://placehold.co/200x200/dddddd/999999/png")
}

