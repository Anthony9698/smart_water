//
//  PlantCard.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct PlantCardView: View {
    let name: String
    let lastWatered: String
    
    var body: some View {
        HStack() {
            Text(name)
                .foregroundStyle(Color.black)
            Spacer()
            HStack() {
                Image(systemName: "drop.fill").foregroundStyle(Color.blue)
                    .padding(2)
                Text(lastWatered)
                    .foregroundStyle(Color.black)
                    .italic()
            }
        }
        .padding(8)
        .background(Color.gray)
        .frame(width: 350, height: 65)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    PlantCardView(name: "Monstera", lastWatered: "3 days ago")
}
