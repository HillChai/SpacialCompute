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
    
//    @Published var CameraState: String = "NotStartNotStartNotStartNotStartNotStart"
    @Published var sessionInfolLabel: String = ""
    
    //photosRecordingSymbol
    @Published var photoFlag: Bool = false
    //attitudeRecordingSymbol
    @Published var attitudeFlag: Bool = false
    
    @Published var snapFlag: Bool = false
    
    //savePath
    @Published var recordingTime: String  = ""
    
    //attitudes, photos, BLE
    var jsonObject: [attitudesPhotosBLE] = []
    let BLE = BlueToothViewModel.instance
    
    func StartSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        session.delegate = self
        session.run(configuration)
    }
    
    func StopSession() {
        session.pause()
    }
    
    // 3. Save it
    func SavePhotos(currentFrame: ARFrame, pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("Error getting cgImage.")
            return
        }
        
        let uiImage = UIImage(cgImage: cgImage, scale: 1, orientation: .right).jpegData(compressionQuality: 1.0)
        
        let currentTime = String(format: "%f", currentFrame.timestamp)
        
        guard let path = getPathForImage(folderName: recordingTime, name: currentTime) else { return }
        
        DispatchQueue.global(qos: .utility).async {
            do {
                try uiImage?.write(to: path)
    //            print("Image wrote successfully!!")
            } catch let error {
                print("Error saving. \(error)")
            }
        }
    }
    
    func SaveAttitudes(currentframe: ARFrame) {
        let currentTime = String(format: "%f", currentframe.timestamp)
        let arCamera = currentframe.camera
        let positions = positionFromTransform(arCamera.transform)
        let eulerAngles = arCamera.eulerAngles
        let BLEmessages = BLE.completemessage
        let frameData = attitudesPhotosBLE(id: currentTime, position: [positions.x, positions.y, positions.z], eulerAngle: [eulerAngles.x, eulerAngles.y, eulerAngles.z], BLEmessage: BLEmessages)
        
        jsonObject.append(frameData)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        CameraState = frame.camera.trackingState.presentationString
        
        if snapFlag == true {
            
            SavePhotos(currentFrame: frame, pixelBuffer: frame.capturedImage)
            SaveAttitudes(currentframe: frame)
            
            snapFlag = false
        }
        
        
        if attitudeFlag == true {
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.SavePhotos(currentFrame: frame, pixelBuffer: frame.capturedImage)
            }
                self.SaveAttitudes(currentframe: frame)
        }
        
    }
 
}

// Mark: Private Method
extension CustomARViewModel {
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String

        switch trackingState {
        case .normal where frame.anchors.isEmpty:
            // No planes detected; provide instructions for this app's AR interactions.
            message = "Move the device around to detect horizontal and vertical surfaces."
            
        case .notAvailable:
            message = "Tracking unavailable."
            
        case .limited(.excessiveMotion):
            message = "Tracking limited - Move the device more slowly."
            
        case .limited(.insufficientFeatures):
            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
            
        case .limited(.initializing):
            message = "Initializing AR session."
            
        default:
            // No feedback needed when tracking is normal and planes are visible.
            // (Nor when in unreachable limited-tracking states.)
            message = ""

        }

        sessionInfolLabel = message
    }
    
}

// Mark: Video Recording

extension CustomARViewModel {
    
    func StartRecordingAttitudes() {
        attitudeFlag = true
        
        recordingTime = getFolderName()
        createFolderIfNeeded(fileFolder: recordingTime)
        
    }
    
    func StopRecordingAttitudes() {
        attitudeFlag = false
//        print(jsonObject)
        
        if recordingTime != "" {
            guard let path = getPathForJson(folderName: recordingTime, name: recordingTime) else { return }
            do {
                let bigData = try? JSONEncoder().encode(jsonObject)
                try bigData?.write(to: path, options: [.atomic])
                print("Json finished")
                jsonObject.removeAll()
            } catch let error {
                print("Errors: \(error)")
            }
        }
    }
    
}

