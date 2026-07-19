//
//  MoistureSensor.swift
//  smart_water
//
//  Created by Anthony Viera on 7/19/26.
//

import Foundation

struct MoistureSensor: Identifiable, Decodable {
    let entityId: String
    let name: String
    let state: Double?
    let unit: String?
    let available: Bool

    var id: String {
        entityId
    }
}
