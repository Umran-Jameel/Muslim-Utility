//
//  Structs.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 4/3/22.
//

import Foundation
/*
struct Qibla: Decodable {
    let data: Direction
}

struct Direction: Decodable {
    let direction: Double
}
*/

// Prayer Times
struct PrayerData: Decodable {
    let data: [Timings]
}

struct Timings: Decodable {
    let timings: [String: String]
    let date: Days
}

struct Days: Decodable {
    let gregorian: Year
    let hijri: Year
}

struct Year: Decodable {
    let day: String
    let month: Month
    let year: String
}

struct Month: Decodable {
    let number: Int
    let en: String
}

let names = [0: "Fajr", 2: "Dhuhr", 3: "Asr", 4: "Maghreb", 5: "Ishaa", 1: "Sunrise"]
