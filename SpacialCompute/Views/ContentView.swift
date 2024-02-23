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
    let customARView = CustomARView.instance
    
    var body: some View {
        NavigationStack {
            ZStack  {
                
                ARViewContainer()
                
                VStack {
                    
                    Spacer()
                    
                    ContinueButton(refreshIsNeeded: $refreshIsNeeded, countinuousIsOn: $countinuousIsOn)
                        .padding()
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text(customARView.CameraState)
                        .font(.title2)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    
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
                        refreshIsNeeded = 0
                        countinuousIsOn = false
                        customARView.StartSession()
                        
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .resizable()
                            .foregroundStyle(.black)
                            .frame(width: 30, height: 30)
                    }
                }
                
            }
            
        }
        
    }
}

#Preview {
    ContentView()
}
