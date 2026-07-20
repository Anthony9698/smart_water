//
//  PlantRequests.swift
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

struct UpdatePlantRequest: Encodable {
    let name: String
    let roomId: String

    let species: String?
    let moistureEntityId: String?

    enum CodingKeys: String, CodingKey {
        case name
        case roomId
        case species
        case moistureEntityId
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )

        try container.encode(
            name,
            forKey: .name
        )

        try container.encode(
            roomId,
            forKey: .roomId
        )

        if let species {
            try container.encode(
                species,
                forKey: .species
            )
        } else {
            try container.encodeNil(
                forKey: .species
            )
        }

        if let moistureEntityId {
            try container.encode(
                moistureEntityId,
                forKey: .moistureEntityId
            )
        } else {
            try container.encodeNil(
                forKey: .moistureEntityId
            )
        }
    }
}
