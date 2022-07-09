//
//  LaunchView.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 7/2/22.
//

import SwiftUI

struct LaunchView: View {
    
    @AppStorage("First time") var firstTime = true
    
    @ObservedObject private var locationManager = LocationManager()
    
    let networkReachability = NetworkReachability()
    
    @Environment(\.colorScheme) var colorScheme
    
    @State var isActive: Bool = true
    @State var first_time_no_wifi: Bool = false
    
    var body: some View {
        if !isActive {
            ContentView()
        } else {
            ZStack {
                Color("main").ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(colorScheme == .dark ? "iconLight" : "icon")
                        .resizable()
                        .frame(width: 150, height: 128)
                    if firstTime {
                        Button(action: {
                            if networkReachability.checkConnection() {
                                isActive.toggle()
                                firstTime.toggle()
                            } else {
                                first_time_no_wifi = true
                            }
                                
                        }, label: {
                            Text("Continue")
                                .font(Font.custom("Ubuntu-Light", size: 25))
                                .frame(width: 200, height: 50)
                                .foregroundColor(Color("default_text"))
                        })
                    }
                }
                .alert(isPresented: $first_time_no_wifi) {
                    Alert(title: Text("No network connection"), message: Text("Try again later"))
                }
            }
            .onAppear {
                if !firstTime {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isActive.toggle()
                    }
                }
            }
        }
        
    }
}
