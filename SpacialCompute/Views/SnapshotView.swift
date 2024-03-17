//
//  SnapshotView.swift
//  SpacialCompute
//
//  Created by cccc on 2024/3/17.
//

import SwiftUI

struct SnapshotView: View {
    //Refresh Bool
    @State var refreshIsNeeded: Int = 0
    //play or stop button
    @State var countinuousIsOn: Bool = false
    
    //ARView
    @StateObject var customARView = CustomARView.instance
    
    var body: some View {
        ZStack  {
            
            ARViewContainer()
//                .frame(height: 615)
//                .offset(y:16)
            
            VStack {
                
                Spacer()
                
                Text(customARView.sessionInfolLabel)
                    .padding(.horizontal)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                
                HStack {
                    
                    Button(action: {
                        if customARView.recordingTime != "" {
                            guard let path = getPathForJson(folderName: customARView.recordingTime, name: customARView.recordingTime) else { return }
                            do {
                                let bigData = try? JSONEncoder().encode(customARView.jsonObject)
                                try bigData?.write(to: path, options: [.atomic])
                                print("Json finished")
                                customARView.jsonObject.removeAll()
                            } catch let error {
                                print("Errors: \(error)")
                            }
                        }
                    }, label: {
                        Image(systemName: "square.and.arrow.down.fill")
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: 50, height: 50)
                    })
                    .padding()
                    
                    Button(action: {
                        customARView.snapFlag = true
                    }, label: {
                        Image(systemName: "camera.circle.fill")
                            .resizable()
                            .foregroundStyle(.white)
                            .frame(width: 55, height: 55)
                    })
                    .padding()
                    
                }
                
            }
            
            
            
        }
        .toolbar(content: {
//            ToolbarItem(placement: .topBarLeading) {
//                Text(customARView.CameraState)
//                    .font(.title2)
//                    .truncationMode(.tail)
//                    .lineLimit(1)
//            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    customARView.StopSession()
                    countinuousIsOn = false
                    customARView.StopRecordingAttitudes()
                    refreshIsNeeded = 0
                    customARView.StartSession()
                    customARView.recordingTime = getFolderName()
                    createFolderIfNeeded(fileFolder: customARView.recordingTime)
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .foregroundStyle(.blue)
                        .frame(width: 30, height: 30)
                }
            }
        })
    }
}

#Preview {
    SnapshotView()
}
