//
//  StreamingView.swift
//  SpacialCompute
//
//  Created by cccc on 2024/3/17.
//

import SwiftUI
import RealityKit

struct StreamingView: View {
    
    
    //Refresh Bool
    @State var refreshIsNeeded: Int = 0
    //play or stop button
    @State var countinuousIsOn: Bool = false
    
    //ARView
    @StateObject var customARView = CustomARView.instance
    
    var body: some View {
        ZStack  {
            
            ARViewContainer()
            
            VStack {
                Spacer()
                
                Text(customARView.sessionInfolLabel)
                    .padding(.horizontal)
                    .background(Color.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                ContinueButton(refreshIsNeeded: $refreshIsNeeded, countinuousIsOn: $countinuousIsOn)
                    .padding()
                
            }
        }
        .toolbar(content: {
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    customARView.StopSession()
                    countinuousIsOn = false
                    customARView.StopRecordingAttitudes()
                    refreshIsNeeded = 0
                    customARView.StartSession()
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
    StreamingView()
}
