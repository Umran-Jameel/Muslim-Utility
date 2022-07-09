//
//  APIRequests.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 4/2/22.
//

import Foundation

/*
func getQibla(response: Data) -> Double {
    let ret: Qibla = try! JSONDecoder().decode(Qibla.self, from: response) // JSON parse
    return ret.data.direction // direction
}

func apiQibla(latitude: Double, longitude: Double) -> Data {
    return API().get("https://api.aladhan.com/v1/qibla/\(latitude)/\(longitude)").data(using: .utf8)! // get data -> API.m
}
 */

// Prayer Times
func getPrayerTimes(response: Data) -> PrayerData {
    let ret: PrayerData = try! JSONDecoder().decode(PrayerData.self, from: response)
    return ret
}

func apiPrayerTime(latitude: Double, longitude: Double, school: Int, month: Int, year: Int) -> Data {
    return API().get("https://api.aladhan.com/v1/calendar?latitude=\(latitude)&longitude=\(longitude)&school=\(school)&month=\(month)&year=\(year)").data(using: .utf8)!
}
