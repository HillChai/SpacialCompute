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
    @Published var recordingTime: String  = ""
    
    //attitudes, photos, BLE
    private var jsonObject: [attitudesPhotosBLE] = []
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
        
        print("Folder Created!")
    }
    
    // 2. Get the path to save photos
    func getPathForImage(folderName: String, name: String) -> URL? {
//        createFolderIfNeeded(fileFolder: folderName)
        
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .appendingPathComponent("\(name).jpg") else {
            print("Error getting image path.")
            return nil
        }
        
//        print("Image path exists!")
        return path
    }
    
    func getPathForJson(folderName: String, name: String) -> URL? {
        
        guard
            let path = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .first?
                .appendingPathComponent(folderName)
                .appendingPathComponent("\(name).json") else {
            print("Error getting json path.")
            return nil
        }
        
        print("Json path created!")
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
        
        guard let path = getPathForImage(folderName: recordingTime, name: currentTime) else { return }
        
        do {
            try uiImage?.write(to: path)
//            print("Image wrote successfully!!")
        } catch let error {
            print("Error saving. \(error)")
        }
        
    }
    
    func StartRecordingAttitudes() {
        attitudeFlag = true
        
        recordingTime = getFolderName()
        createFolderIfNeeded(fileFolder: recordingTime)
        
    }
    
    func getFolderName() -> String {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        return String(day)+"-"+String(hour)+"-"+String(minutes)+"-"+String(second)
    }
    
    func positionFromTransform(_ transform: matrix_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
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
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        CameraState = frame.camera.trackingState.presentationString
        
        if attitudeFlag == true {
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.SavePhotos(currentFrame: frame, pixelBuffer: frame.capturedImage)
            }
                self.SaveAttitudes(currentframe: frame)
//            }
        }
        
    }
 
}


