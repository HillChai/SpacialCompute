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


class CustomARViewModel: ARView, ARSessionDelegate {
    
    @Published var CameraState: String = "Not Start"
    
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
//        actionStream
//            .sink { [weak self] action in
//                switch action {
//                case .notAvailable:
//                    self?.CameraState = "notAvailable"
//                case .limited:
//                    self?.CameraState = "limited"
//                case .normal:
//                    self?.CameraState = "normal"
//                }
//            }
//            .store(in: &cancellables)
        CameraState = frame.camera.trackingState.presentationString
    }
    
}
