//
//  CardView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/10/26.
//

import SwiftUI


struct RoomCardView: View {
    let name: String
    let numPumps: Int
    let iconName: String

    var body: some View {
        VStack() {
            Text(name)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Image(systemName: iconName)
                .font(.system(size: 46))
                .foregroundStyle(.blue)

            Text("\(numPumps) Water " + (numPumps > 1 || numPumps == 0 ? "Pumps" : "Pump"))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(.green.opacity(0.65))
                .clipShape(Capsule())

            Spacer()
        }
        .padding()
        .frame(width: 150, height: 150)
        .background(Color(.gray).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    RoomCardView(name: "Primary", numPumps: 2, iconName: "bed.double.fill")
}

#Preview {
    RoomCardView(name: "Living Room", numPumps: 1, iconName: "sofa.fill")
}

#Preview {
    RoomCardView(name: "Kitchen", numPumps: 0, iconName: "stove.fill")
}

#Preview {
    RoomCardView(name: "Office", numPumps: 0, iconName: "desktopcomputer")
}

