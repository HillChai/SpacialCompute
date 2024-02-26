//
//  ContinueButton.swift
//  SpacialCompute
//
//  Created by cccc on 2024/2/24.
//

import SwiftUI
import ARKit

struct ContinueButton: View {
    @Binding var refreshIsNeeded: Int
    @Binding var countinuousIsOn: Bool
    
    let ARViewModel = CustomARView.instance
    
    var body: some View {
        Button {
            
            if refreshIsNeeded < 2 {
                countinuousIsOn.toggle()
            }
            refreshIsNeeded += 1
            
            if countinuousIsOn {
                ARViewModel.StartRecordingPhotos()
                ARViewModel.StartRecordingAttitudes()
            } else {
                ARViewModel.StopRecordingPhotos()
                ARViewModel.StopRecordingAttitudes()
            }
            
            
        } label: {
            Image(systemName: countinuousIsOn ? "stop.circle.fill" : "play.circle.fill")
                .resizable()
                .foregroundStyle(.red)
                .frame(width: 55, height: 55)
        }
        
    }
    
}


//Continuous

#Preview {
    ContinueButton(refreshIsNeeded: .constant(0), countinuousIsOn: .constant(false))
//        .background(Color.red)
}
