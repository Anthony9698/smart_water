//
//  CardView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/10/26.
//

import SwiftUI


struct RoomCardView: View {
    let room: Room

    var body: some View {
        VStack {
            Text(room.name)

            Text(plantCountText)
        }
        .padding()
        .frame(width: 150, height: 150)
        .background(Color(.gray).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var plantCountText: String {
        room.plantCount == 1
            ? "1 Plant"
            : "\(room.plantCount) Plants"
    }
}

#Preview {
    RoomCardView(room: Room(id: "1", name: "kitchen", plantCount: 2))
}

