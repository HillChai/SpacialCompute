//
//  ARViewContainer.swift
//  SpacialCompute
//
//  Created by cccc on 2024/3/19.
//

import Foundation
import SwiftUI

struct SnapshotContainer: UIViewRepresentable {
    
    static var instance = SnapshotContainer()
    
    func makeUIView(context: Context) -> some UIView {
        let arView = ARViewContainer.instanceForSnapshot
//        arView.debugOptions = [.showFeaturePoints]
            
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
}

struct RecordingContainer: UIViewRepresentable {
    
    static var instance = RecordingContainer()
    
    func makeUIView(context: Context) -> some UIView {
        let arView = ARViewContainer.instanceForRecording
//        arView.debugOptions = [.showFeaturePoints]   //Product -> Scheme -> Edit Scheme -> Run -> Diagnostic -> Metal
        return arView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
    }
    
}

struct ARViewContainer {
    static var instanceForRecording = CustomARViewModel()
    static var instanceForSnapshot = CustomARViewModel()
}
