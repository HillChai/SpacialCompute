//
//  UIView.swift
//  SpacialCompute
//
//  Created by cccc on 2024/2/24.
//

import Foundation
import SwiftUI

struct ARViewContainer: UIViewRepresentable {
    
    static var instance = ARViewContainer()
    
    func makeUIView(context: Context) -> some UIView {
        
        return CustomARView.instance
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    
    
}
