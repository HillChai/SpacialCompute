//
//  attitudesPhotosBLE.swift
//  SpacialCompute
//
//  Created by cccc on 2024/2/27.
//

import Foundation

struct attitudesPhotosBLE: Identifiable, Codable {
    let id: String
    let position: [Float]
    let eulerAngle: [Float]
    let BLEmessage: String
}

