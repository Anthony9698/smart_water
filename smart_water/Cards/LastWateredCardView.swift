//
//  LastWateredCardView.swift
//  smart_water
//
//  Created by Anthony Viera on 7/12/26.
//

import SwiftUI

struct LastWateredCardView: View {
    let lastWatered: String
    let timeWateredSeconds: Int
    
    var body: some View {
        HStack() {
            Text(lastWatered)
                .foregroundStyle(Color.black)
            Spacer()
            VStack(alignment: .center) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(Color.teal)
                Text(String(timeWateredSeconds) + " Seconds")
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
    LastWateredCardView(lastWatered: "Today", timeWateredSeconds: 5)
}
