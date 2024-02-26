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
    
    //savePath
    private var recordingTime: String  = "now"
    
    func StartSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        session.delegate = self
        session.run(configuration)
    }
    
    func StopSession() {
        session.pause()
    }
    
    // 1. Check whether the folder exitst
    func createFolderIfNeeded(fileFolder folderName: String) {
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .path else { return }
        
        //Check whether the target folder exists.
        if !FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true)
                print("Success creating folder.")
            } catch let error {
                print("Error creating folder. \(error)")
            }
        }
    }
    
    // 2. Get the path to save photos
    func getPathForImage(folderName: String, name: String) -> URL? {
        
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .appendingPathComponent("\(name).jpg") else {
            print("Error getting path.")
            return nil
        }
        
        return path
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
        print("currentTime: \(currentTime)")
        
        guard let path = getPathForImage(folderName: recordingTime, name: currentTime) else { return }
        print("path: \(path)")
        do {
            try uiImage?.write(to: path)
        } catch let error {
            print("Error saving. \(error)")
        }
        
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
        
//            SavePhotos(currentFrame: frame, pixelBuffer: frame.capturedImage)
            
        
        if attitudeFlag == true {
            DispatchQueue.global(qos: .utility).async {
                self.SavePhotos(currentFrame: frame, pixelBuffer: frame.capturedImage)
                self.SaveAttitudes()
            }
        }
    }
 
}


