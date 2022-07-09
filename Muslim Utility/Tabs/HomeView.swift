//
//  HomeView.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 4/7/22.
//

import SwiftUI
import CoreLocation

struct HomeView: View {
    @AppStorage("currentMonthTimes") var currentMonthTimes = apiPrayerTime(latitude: 28.5384, longitude: -81.3789, school: 0, month: Calendar.current.component(.month, from: Date()), year: Calendar.current.component(.year, from: Date()))
    @AppStorage("timeUntilNextPrayer") var timeUntilNextPrayer = ""
    @AppStorage("nextPrayerTime") var nextPrayerTime = "00:00"
    @AppStorage("currentPrayer") var currentPrayer = 0
    @AppStorage("school") var school = false
    
    @AppStorage("format") var format = false // false is 12, true is 24
    
    @AppStorage("latitude") var lat = 0.0
    @AppStorage("longitude") var long = 0.0
    @AppStorage("currentLocation") var currentCity = "Orlando, FL"
    @AppStorage("Previous City") var previousCity = ""
    
    @AppStorage("Current Year") var currentYear = Calendar.current.component(.year, from: Date())
    @AppStorage("currentDay") var day = Calendar.current.component(.day, from: Date())
    @AppStorage("Current Month") var currentMonth = Calendar.current.component(.month, from: Date())
    
    @AppStorage("Fajr") var fajr = ""
    @AppStorage("Dhuhr") var dhuhr = ""
    @AppStorage("Asr") var asr = ""
    @AppStorage("Maghreb") var maghreb = ""
    @AppStorage("Isha") var isha = ""
    @AppStorage("Sunrise") var sunrise = ""
    
    @AppStorage("Hijri Date") var hijriDate = ""
    @AppStorage("Gregorian Date") var gregorianDate = ""
    
    @State var timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    @State var timeNow = ""
    
    @State var flag = 0
    
    @State var alertLocation = false
    @State var alertedLocation = false
    
    @State var alertConnection = false
    @State var alertedConnection = false
    
    @ObservedObject private var locationManager = LocationManager()
    let locationProvider = LocationProvider()
    
    @Environment(\.colorScheme) var colorScheme // to know which image to display
    
    let networkReachability = NetworkReachability()
    
    var body: some View {
        var notAuthorized = CLLocationCoordinate2D()
        notAuthorized.latitude = 9999.8
        notAuthorized.longitude = 9999.8
        let coordinates = self.locationManager.location != nil ? self.locationManager.location!.coordinate : notAuthorized
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        DispatchQueue.main.async { self.timeNow = dateFormatter.string(from: Date()) }
        
        return ZStack {
            Color("main").ignoresSafeArea()
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color("main"))
                        .frame(width: 340, height: 150)
                    VStack {
                        HStack {
                            PlainText(text: self.hijriDate, bold: false, size: 17, color: "date")
                                .padding(.leading)
                            Spacer()
                            PlainText(text: self.gregorianDate, bold: false, size: 17, color: "date")
                                .padding(.trailing)
                        }
                        Text(timeNow.tentative(format: self.format))
                            .onReceive(timer) { _ in // every second we...
                                self.timeNow = dateFormatter.string(from: Date()) // update the time
                                
                                let day = Calendar.current.component(.day, from: Date())
                                let month = Calendar.current.component(.month, from: Date())
                                let year = Calendar.current.component(.year, from: Date())
                                
                                var prayerTimes: PrayerData?
                                
                                let isConnected = networkReachability.checkConnection()
                                
                                // check if there's a change in the date
                                if self.day != day || self.currentMonth != month || self.currentYear != year {
                                    // if there's a different month or year
                                    if self.currentYear != year || self.currentMonth != month {
                                        // and we're not connected to internet, let the user know and do nothing
                                        if !isConnected {
                                            if !alertedConnection {
                                                alertConnection = true
                                                alertedConnection = true
                                            }
                                        } else { // if we're connected, call the api for that month
                                            self.currentYear = year
                                            self.currentMonth = month
                                            self.currentMonthTimes = apiPrayerTime(latitude: self.lat, longitude: self.long, school: self.school == false ? 0 : 1, month: self.currentMonth, year: self.currentYear)
                                        }
                                    }
                                    prayerTimes = getPrayerTimes(response: self.currentMonthTimes) // read the times
                                    self.day = day
                                    updateTimes(prayerTimes: prayerTimes!) // and update
                                }
                                
                                // location will only be accessed if authorized by the user...
                                if coordinates.authorized() {
                                    // and we're connected to wifi
                                    if isConnected {
                                        if self.lat != coordinates.latitude || self.long != coordinates.longitude {
                                            self.lat = coordinates.latitude
                                            self.long = coordinates.longitude
                                            getCity() // reverse geocode
                                        }
                                        
                                        // get the new prayer times if the user is in a new city
                                        if self.previousCity != self.currentCity {
                                            self.previousCity = self.currentCity
                                            self.currentMonthTimes = apiPrayerTime(latitude: self.lat, longitude: self.long, school: self.school == false ? 0 : 1, month: self.currentMonth, year: self.currentYear)
                                            prayerTimes = getPrayerTimes(response: self.currentMonthTimes)
                                            updateTimes(prayerTimes: prayerTimes!)
                                        }
                                    } else {
                                        if !alertedConnection {
                                            alertConnection = true
                                            alertedConnection = true
                                        }
                                    }
                                } else { // if location not authorized, let the user know
                                    if !alertedLocation {
                                        alertLocation = true
                                        alertedLocation = true
                                    }
                                }
                                
                                if prayerTimes == nil {
                                    prayerTimes = getPrayerTimes(response: self.currentMonthTimes)
                                }
                                
                                // know the next prayer and its time and the time until the next prayer
                                findCurrentPrayerAndNextTime(prayerTimes: prayerTimes!)
                            }
                            .onAppear(perform: {dateFormatter.dateFormat = "h:mm a"})
                            .font(Font.custom("Ubuntu-Light", size: 65))
                            .foregroundColor(Color("default_text"))
                            .alert(isPresented: $alertLocation) {
                                Alert(title: Text("Location is required to show prayer times for your area"), message: Text("Enable Location in settings"), primaryButton: .default(Text("Settings").bold(), action: {
                                    if let bundleID = Bundle.main.bundleIdentifier, let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleID)")  {
                                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                    }
                                }), secondaryButton: .default(Text("Cancel"), action: { alertLocation = false }))
                            }
                            .alert(isPresented: $alertConnection) {
                                Alert(
                                    title: Text("Check Network Connection"),
                                    message: Text("Network connection required to update timings"),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                            
                        HStack {
                            Text("\((names[self.currentPrayer + 1] ?? names[0])!)")
                                .font(Font.custom("Ubuntu-Bold", size: 20))
                                .foregroundColor(Color("default_text"))
                            Text("in")
                                .font(Font.custom("Ubuntu-Light", size: 20))
                                .foregroundColor(Color("default_text"))
                            Text("\(self.timeUntilNextPrayer)")
                                .font(Font.custom("Ubuntu-Bold", size: 20))
                                .foregroundColor(Color("default_text"))
                        }
                    }
                }
                ZStack {
                    VStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(self.currentPrayer == 0 ? "current_prayer" : "prayer_time"))
                            .frame(width: 340, height: 55)
                            .overlay(
                                Group {
                                    IndividualTime(name: "Fajr", time: self.fajr.tentative(format: self.format), arabic: "الفجر", currentPrayer: self.currentPrayer)
                                            .padding(2)
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color("prayer_time_border"))
                                })
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color("prayer_time"))
                            .frame(width: 340, height: 55)
                            .overlay(
                                Group {
                                    IndividualTime(name: "Sunrise", time: self.sunrise.tentative(format: self.format), arabic: "الشروق", currentPrayer: self.currentPrayer)
                                        .padding(2)
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color("prayer_time_border"))
                                })
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(self.currentPrayer == 2 ? "current_prayer" : "prayer_time"))
                            .frame(width: 340, height: 55)
                            .overlay(
                                Group {
                                    IndividualTime(name: "Dhuhr", time: self.dhuhr.tentative(format: self.format), arabic: "الظهر", currentPrayer: self.currentPrayer)
                                            .padding(2)
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color("prayer_time_border"))
                                })
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(self.currentPrayer == 3 ? "current_prayer" : "prayer_time"))
                            .frame(width: 340, height: 55)
                            .overlay(
                                Group {
                                    IndividualTime(name: "Asr", time: self.asr.tentative(format: self.format), arabic: "العصر", currentPrayer: self.currentPrayer)
                                            .padding(2)
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color("prayer_time_border"))
                                })
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(self.currentPrayer == 4 ? "current_prayer" : "prayer_time"))
                            .frame(width: 340, height: 55)
                            .overlay(
                                Group {
                                    IndividualTime(name: "Maghreb", time: self.maghreb.tentative(format: self.format), arabic: "المغرب", currentPrayer: self.currentPrayer)
                                            .padding(2)
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color("prayer_time_border"))
                                })
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(self.currentPrayer == 5 ? "current_prayer" : "prayer_time"))
                            .frame(width: 340, height: 55)
                            .overlay(
                                Group {
                                    IndividualTime(name: "Ishaa", time: self.isha.tentative(format: self.format), arabic: "العشاء", currentPrayer: self.currentPrayer)
                                            .padding(2)
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color("prayer_time_border"))
                                })
                        Text("\(self.currentCity) \(Image(systemName: "location.fill"))")
                            .font(Font.custom("Ubuntu-Light", size: 20))
                            .foregroundColor(Color("default_text"))
                            .padding(15)
                        
                        
                        Image(colorScheme == .dark ? "iconLight" : "icon")
                            .resizable()
                            .frame(width: 70, height: 60)
                    }
                }
                Spacer()
            }
        }
        
    }
    
    func updateTimes(prayerTimes: PrayerData) {
        self.fajr = String(prayerTimes.data[self.day - 1].timings["Fajr"]!.prefix(5))
        self.dhuhr = String(prayerTimes.data[self.day - 1].timings["Dhuhr"]!.prefix(5))
        self.asr = String(prayerTimes.data[self.day - 1].timings["Asr"]!.prefix(5))
        self.maghreb = String(prayerTimes.data[self.day - 1].timings["Maghrib"]!.prefix(5))
        self.isha = String(prayerTimes.data[self.day - 1].timings["Isha"]!.prefix(5))
        self.sunrise = String(prayerTimes.data[self.day - 1].timings["Sunrise"]!.prefix(5))
        
        self.gregorianDate = "\(prayerTimes.data[self.day - 1].date.gregorian.day) \(prayerTimes.data[self.day - 1].date.gregorian.month.en) \(prayerTimes.data[self.day - 1].date.gregorian.year)"
        self.hijriDate = "\(prayerTimes.data[self.day - 1].date.hijri.day) \(prayerTimes.data[self.day - 1].date.hijri.month.en) \(prayerTimes.data[self.day - 1].date.hijri.year)"
    }
    
    // O(log 6) kinda binary search
    func findCurrentPrayerAndNextTime(prayerTimes: PrayerData) {
        switch compareTime(time1: self.timeNow.tentative(format: true), time2: self.asr) {
        case 1:
            switch compareTime(time1: self.timeNow.tentative(format: true), time2: self.maghreb) {
            case 1:
                switch compareTime(time1: self.timeNow.tentative(format: true), time2: self.isha) {
                case 3:
                    self.currentPrayer = 4
                    self.nextPrayerTime = String(prayerTimes.data[self.day - 1].timings["Isha"]!.prefix(5))
                    break
                default:
                    self.currentPrayer = 5
                    if !prayerTimes.data.indices.contains(self.day) {
                        self.currentMonthTimes = apiPrayerTime(latitude: self.lat, longitude: self.long, school: self.school == false ? 0 : 1, month: Calendar.current.component(.month, from: Date()), year: Calendar.current.component(.year, from: Date()))
                    } else {
                        self.nextPrayerTime = String(prayerTimes.data[self.day].timings["Fajr"]!.prefix(5))
                    }
                    break
                }
                break
            case 2:
                self.currentPrayer = 4
                self.nextPrayerTime = String(prayerTimes.data[self.day - 1].timings["Isha"]!.prefix(5))
                break
            default:
                self.currentPrayer = 3
                self.nextPrayerTime = String(prayerTimes.data[self.day - 1].timings["Maghrib"]!.prefix(5))
                break
            }
            break
        case 2:
            self.currentPrayer = 3
            self.nextPrayerTime = String(prayerTimes.data[self.day - 1].timings["Maghrib"]!.prefix(5))
            break
        default:
            switch compareTime(time1: self.timeNow.tentative(format: true), time2: self.sunrise) {
            case 1:
                switch compareTime(time1: self.timeNow.tentative(format: true), time2: self.dhuhr) {
                case 3:
                    self.currentPrayer = 1
                    self.nextPrayerTime = String(prayerTimes.data[self.day - 1].timings["Dhuhr"]!.prefix(5))
                    break
                default:
                    self.currentPrayer = 2
                    self.nextPrayerTime = String(prayerTimes.data[self.day - 1].timings["Asr"]!.prefix(5))
                    break
                }
                break
            case 2:
                self.currentPrayer = 1
                self.nextPrayerTime = String(prayerTimes.data[self.day - 1].timings["Dhuhr"]!.prefix(5))
                break
            default:
                switch compareTime(time1: self.timeNow.tentative(format: true), time2: fajr) {
                case 1:
                    self.currentPrayer = 1
                    self.nextPrayerTime = String(prayerTimes.data[self.day - 1].timings["Dhuhr"]!.prefix(5))
                    break
                default:
                    self.currentPrayer = 0
                    self.nextPrayerTime = String(prayerTimes.data[self.day - 1].timings["Sunrise"]!.prefix(5))
                    break
                }
                break
            }
            break
        }
        self.timeUntilNextPrayer = calculateTime(time1: self.nextPrayerTime, time2: timeNow.tentative(format: true))
    }
    
    func getCity() {
        let location = CLLocation(latitude: self.lat, longitude: self.long)
            
        locationProvider.getPlace(for: location) { plsmark in
            guard let placemark = plsmark else { return }
            if let city = placemark.locality, let state = placemark.administrativeArea {
                self.currentCity = "\(city), \(state)"
            } else {
                self.currentCity = "-----"
            }
        }
    }
    
}
