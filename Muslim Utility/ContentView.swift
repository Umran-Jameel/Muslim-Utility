//
//  ContentView.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 4/1/22.

import SwiftUI
import UserNotifications

struct ContentView: View {
    @AppStorage("school") var school = false
    
    @AppStorage("format") var format = false // false is 12, true is 24
    
    init() {
        UITabBar.appearance().barTintColor = .white
    }
    
    var body: some View {
        TabView {
            HomeView().tabItem {
                Image(systemName: "clock.fill")
                Text("Prayer Times")
            }.onAppear {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                AppDelegate.orientationLock = .portrait
            }
            PreferencesView(passedFormat: self.$format, passedSchool: self.$school).tabItem {
                Image(systemName: "gearshape.fill")
                Text("Preferences")
            }.onAppear {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                AppDelegate.orientationLock = .portrait
            }
        }
    }
}

