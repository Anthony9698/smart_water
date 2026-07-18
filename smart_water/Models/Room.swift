//
//  Room.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import Foundation

struct Room: Identifiable, Decodable {
    let id: String
    let name: String
    let plantCount: Int
}
