//
//  PreferencesView.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 4/8/22.
//

import SwiftUI
import CoreLocation
import CoreLocationUI

struct PreferencesView: View {
    @Binding var localFormat: Bool
    @Binding var localSchool: Bool
    
    @AppStorage("format") var format = false
    @AppStorage("school") var school = false
    
    @AppStorage("latitude") var lat = 0.0
    @AppStorage("longitude") var long = 0.0
    
    @AppStorage("currentMonthTimes") var currentMonthTimes = apiPrayerTime(latitude: 28.5384, longitude: -81.3789, school: 0, month: Calendar.current.component(.month, from: Date()), year: Calendar.current.component(.year, from: Date()))
    
    @AppStorage("Fajr") var fajr = ""
    @AppStorage("Dhuhr") var dhuhr = ""
    @AppStorage("Asr") var asr = ""
    @AppStorage("Maghreb") var maghreb = ""
    @AppStorage("Isha") var isha = ""
    @AppStorage("Sunrise") var sunrise = ""
    @AppStorage("currentDay") var day = Calendar.current.component(.day, from: Date())
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject var locationManager = LocationManager()
    let locationProvider = LocationProvider()
    
    init(passedFormat: Binding<Bool>, passedSchool: Binding<Bool>) {
        UITableView.appearance().backgroundColor = .clear
        self._localFormat = passedFormat
        self._localSchool = passedSchool
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    // 24 hour time option
                    Toggle(isOn: $localFormat, label: {
                        Text("24-Hour Time")
                            .font(Font.custom("Ubuntu-Light", size: 20))
                    })
                    .onChange(of: localFormat, perform: { value in
                        self.format = value
                    })
                    
                    // Hanafi prayer time option
                    Toggle(isOn: $localSchool, label: {
                        Text("Hanafi Prayer Time")
                            .font(Font.custom("Ubuntu-Light", size: 20))
                    })
                    .onChange(of: localSchool, perform: { value in
                        self.school = value
                        updateTimes()
                    })
                }
                Section {
                    NavigationLink(destination: AboutView()) {
                        Text("About")
                            .font(Font.custom("Ubuntu-Light", size: 20))
                    }
                }
            }
            .background(Color("main").ignoresSafeArea())
            
        }
        
    }
    
    func updateTimes() {
        self.currentMonthTimes = apiPrayerTime(latitude: self.lat, longitude: self.long, school: self.school == false ? 0 : 1, month: Calendar.current.component(.month, from: Date()), year: Calendar.current.component(.year, from: Date()))
        let prayerTimes = getPrayerTimes(response: self.currentMonthTimes)
        self.fajr = String(prayerTimes.data[self.day - 1].timings["Fajr"]!.prefix(5))
        self.dhuhr = String(prayerTimes.data[self.day - 1].timings["Dhuhr"]!.prefix(5))
        self.asr = String(prayerTimes.data[self.day - 1].timings["Asr"]!.prefix(5))
        self.maghreb = String(prayerTimes.data[self.day - 1].timings["Maghrib"]!.prefix(5))
        self.isha = String(prayerTimes.data[self.day - 1].timings["Isha"]!.prefix(5))
        self.sunrise = String(prayerTimes.data[self.day - 1].timings["Sunrise"]!.prefix(5))
    }
}
