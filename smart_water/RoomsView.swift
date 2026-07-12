//
//  RoomsView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct RoomsView: View {
    let rooms = [
        Room(name: "Primary", numPumps: 0, iconName: "bed.double.fill"),
        Room(name: "Living Room", numPumps: 0, iconName: "sofa.fill"),
        Room(name: "Kitchen", numPumps: 1, iconName: "stove.fill"),
        Room(name: "Office", numPumps: 0, iconName: "desktopcomputer")
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 32),
        GridItem(.flexible(), spacing: 32)
    ]
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            header
            Spacer()
            
            LazyVGrid(columns: columns, spacing: 24) {
                ForEach(rooms, id: \.name) { room in
                    RoomCardView(name: room.name, numPumps: room.numPumps, iconName: room.iconName)
                }
            }
            .padding(.horizontal, 128)
            Spacer()
        }
        .padding(.top, 32)
        .padding(.bottom, 32)
        .background(Color.white)
    }
    
    private var header: some View {
        HStack() {
            Text("Rooms")
                .font(.headline)
                .foregroundStyle(Color.black)
                .fontWeight(.bold)
            
            Spacer()
            
            HStack() {
                Image(systemName: "wifi")
                    .foregroundStyle(Color.blue)
                Text("Last ping: Sat, 11 July 2026 12:00:01")
                    .font(.caption)
                    .foregroundStyle(Color.black)
                    .italic()
            }
            
        }
        .padding(.horizontal, 32)
    }
}

struct Room: Identifiable {
    let id = UUID()
    let name: String
    let numPumps: Int
    let iconName: String
}

#Preview {
    RoomsView()
}
