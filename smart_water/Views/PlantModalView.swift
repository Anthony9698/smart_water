//
//  PlantModalView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct PlantModalView: View {
    let name: String
    let pictureUrl: String
    let lastWateredActivity = [
        LastWateredActivity(lastWatered: "Today", timeWateredSeconds: 3),
        LastWateredActivity(lastWatered: "Today", timeWateredSeconds: 3)
    ]
    @Environment(\.dismiss) var dismissModal
    
    var body: some View {
        VStack() {
            HStack() {
                Text(name)
                    .foregroundStyle(Color.black)
                    .padding(24)
                Spacer()
                Button(action: {dismissModal()}) {
                    Image(systemName: "xmark")
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(Color.black)
                }
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
                .clipped()
                
                Button(action: {}) {
                    Text("WATER")
                        .foregroundStyle(Color.white)
                        .frame(width: 100, height: 48)
                        .fontWeight(.bold)

                }
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
            VStack(alignment: .leading) {
                Text("Recent Water Activity")
                    .foregroundStyle(Color.black)
                VStack(spacing: 0) {
                    ForEach(lastWateredActivity, id: \.id) { activity in
                        LastWateredCardView(lastWatered: activity.lastWatered, timeWateredSeconds: activity.timeWateredSeconds)
                    }
                }
            }
            Spacer()
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
    }
}

struct LastWateredActivity: Identifiable {
    let id = UUID()
    let lastWatered: String
    let timeWateredSeconds: Int
}

#Preview {
    @Previewable @State var isShowingStandardModal = false
    VStack() {
        Text("Main Screen")
        Button(action: {isShowingStandardModal = true}) {
            Text("Open Modal")
        }
        .sheet(isPresented: $isShowingStandardModal) {
            PlantModalView(name: "Monstera", pictureUrl: "https://placehold.co/200x200/dddddd/999999/png")
        }
    }
}

