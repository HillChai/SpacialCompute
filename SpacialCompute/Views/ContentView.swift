//
//  ContentView.swift
//  SpacialCompute
//
//  Created by cccc on 2024/2/23.
//

import SwiftUI

struct ContentView: View {
    
    //BLE Settings
    @State var isPresent: Bool = false
    
    //ARView
    @StateObject var customARView = CustomARView.instance
    
    
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
            
                Spacer()
                
                NavigationLink {
                    SnapshotView()
                } label: {
                    Text("拍照模式")
                        .font(.title)
                        .padding()
                        .padding()
                }

                NavigationLink {
                    StreamingView()
                } label: {
                    Text("视频模式")
                        .font(.title)
                        .padding()
                        .padding()
                }
                
                Spacer()
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .sheet(isPresented: $isPresent, content: {
                            BlueTooth()
                        })
                        .onTapGesture(perform: {
                            isPresent.toggle()
                        })
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
