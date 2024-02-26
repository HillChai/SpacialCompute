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
    
    @Published var CameraState: String = "NotStartNotStartNotStartNotStartNotStart"
    
    //photosRecordingSymbol
    @Published var photoFlag: Bool = false
    //attitudeRecordingSymbol
    @Published var attitudeFlag: Bool = false
    
    func StartSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        session.delegate = self
        session.run(configuration)
    }
    
    func StopSession() {
        session.pause()
    }
    
    func StartRecordingPhotos() {
        photoFlag = true
    }
    
    func SavePhotos() {
    }
    
    func StopRecordingPhotos() {
        photoFlag = false
    }
    
    func StartRecordingAttitudes() {
        attitudeFlag = true
    }
    
    func SaveAttitudes() {
    }
    
    func StopRecordingAttitudes() {
        attitudeFlag = false
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        CameraState = frame.camera.trackingState.presentationString
        
        if photoFlag == true {
            SavePhotos()
        }
        
        if attitudeFlag == true {
            SaveAttitudes()
        }
    }
 
}


