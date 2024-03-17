//
//  ContentView.swift
//  SpacialCompute
//
//  Created by cccc on 2024/2/23.
//

import SwiftUI

struct ContentView: View {
    
    @State var currentSelected: Int = 0
    
    var body: some View {
        
        TabView(selection: $currentSelected) {
            
            SnapshotView()
                .tabItem {
                    Image(systemName: "camera")
                    Text("照片")
                }
                .tag(0)
                .onDisappear(perform: {
                    ARViewContainer.instanceForSnapshot.recordingTime = ""
                })
                
            
            StreamingView()
                .tabItem {
                    Image(systemName: "video.fill")
                    Text("视频")
                }
                .tag(1)
                .onDisappear(perform: {
                    ARViewContainer.instanceForRecording.recordingTime = ""
                })
    
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        
    }
    
}

#Preview {
    ContentView()
}
