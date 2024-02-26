//
//  CustomARViewModel.swift
//  SpacialCompute
//
//  Created by cccc on 2024/2/24.
//

import Foundation
import ARKit
import RealityKit
import Combine

//enum trackingState {
//    case notAvailable
//    case limited
//    case normal
//}


class CustomARViewModel: ARView, ARSessionDelegate, ObservableObject {
    
    @Published var CameraState: String = "NotStart"
    
    var actionStream = PassthroughSubject<ARCamera.TrackingState, Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    func StartSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        session.delegate = self
        session.run(configuration)
    }
    
    func StopSession() {
        session.pause()
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        CameraState = frame.camera.trackingState.presentationString
    }
 
}


