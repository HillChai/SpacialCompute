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
        
        let arView = CustomARView.instance
        
        arView.debugOptions = [.showFeaturePoints]   //Product -> Scheme -> Edit Scheme -> Run -> Diagnostic -> Metal
        
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
    
    
}
