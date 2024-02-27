//
//  ContentView.swift
//  SpacialCompute
//
//  Created by cccc on 2024/2/23.
//

import SwiftUI
import RealityKit

struct ContentView: View {
    //BLE Settings
    @State var isPresent: Bool = false
    //Refresh Bool
    @State var refreshIsNeeded: Int = 0
    //play or stop button
    @State var countinuousIsOn: Bool = false
    
    //ARView
    @StateObject var customARView = CustomARView.instance
    
    var body: some View {
        NavigationStack {
            ZStack  {
                
                ARViewContainer()
                    .frame(height: 615)
                    .offset(y:16)
                
                VStack {
                    HStack {
                        Text(customARView.CameraState)
                            .font(.title2)
                            .truncationMode(.tail)
                            .lineLimit(1)
                        
                        Image("bluetooth")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .sheet(isPresented: $isPresent, content: {
                                BlueTooth()
                            })
                            .onTapGesture(perform: {
                                isPresent.toggle()
                            })
                        
                        Button {
                            customARView.StopSession()
                            countinuousIsOn = false
                            customARView.StopRecordingAttitudes()
                            refreshIsNeeded = 0
                            customARView.StartSession()
                        } label: {
                            Image(systemName: "arrow.triangle.2.circlepath")
                                .resizable()
                                .foregroundStyle(.black)
                                .frame(width: 30, height: 30)
                        }
                    }
                    
                    Spacer()
                    
                    ContinueButton(refreshIsNeeded: $refreshIsNeeded, countinuousIsOn: $countinuousIsOn)
                        .padding()
                }
                
            }
            
        }
        
    }
}

#Preview {
    ContentView()
}
