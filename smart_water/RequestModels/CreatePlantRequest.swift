//
//  CreatePlantRequest.swift
//  smart_water
//
//  Created by Anthony Viera on 7/18/26.
//

import Foundation

struct CreatePlantRequest: Encodable {
    let name: String
    let roomId: String
    let species: String?
    let moistureEntityId: String?
}
