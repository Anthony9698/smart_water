//
//  Plant.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import Foundation

struct Plant: Identifiable, Decodable {
    let id: String
    let name: String
    let roomId: String
    let moistureEntityId: String
    let pumpEntityId: String
    let photoUrl: String
}
