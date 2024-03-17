//
//  SIMD+Extensions.swift
//  SpacialCompute
//
//  Created by cccc on 2024/3/18.
//

import Foundation
import ARKit

extension simd_float4x4 {
    init(_ matrix: Matrix) {
        self.init(matrix.col0, matrix.col1, matrix.col2, matrix.col3)
    }
}
