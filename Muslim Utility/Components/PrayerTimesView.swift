//
//  PrayerTimesView.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 4/8/22.
//

import SwiftUI

struct PrayerTimesView: View {
    @AppStorage("currentPrayer") var currentPrayer = 0
    @AppStorage("format") var format = false
    
    @AppStorage("Fajr") var fajr = ""
    @AppStorage("Dhuhr") var dhuhr = ""
    @AppStorage("Asr") var asr = ""
    @AppStorage("Maghreb") var maghreb = ""
    @AppStorage("Isha") var isha = ""
    @AppStorage("Sunrise") var sunrise = ""
    
    var body: some View {
        return VStack {
            IndividualTime(name: "Fajr", time: self.fajr.tentative(format: self.format), arabic: "الفجر", currentPrayer: self.currentPrayer)
                    .padding(2)
            IndividualTime(name: "Sunrise", time: self.sunrise.tentative(format: self.format), arabic: "الشروق", currentPrayer: self.currentPrayer)
                    .padding(2)
            IndividualTime(name: "Dhuhr", time: self.dhuhr.tentative(format: self.format), arabic: "الظهر", currentPrayer: self.currentPrayer)
                    .padding(2)
            IndividualTime(name: "Asr", time: self.asr.tentative(format: self.format), arabic: "العصر", currentPrayer: self.currentPrayer)
                    .padding(2)
            IndividualTime(name: "Maghreb", time: self.maghreb.tentative(format: self.format), arabic: "المغرب", currentPrayer: self.currentPrayer)
                    .padding(2)
            IndividualTime(name: "Ishaa", time: self.isha.tentative(format: self.format), arabic: "العشاء", currentPrayer: self.currentPrayer)
                    .padding(2)
            }
    }
}
