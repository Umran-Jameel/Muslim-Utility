//
//  Functions.swift
//  Muslim Utility
//
//  Created by Umran Jameel on 5/9/22.
//

import Foundation
import CoreLocationUI
import CoreLocation
import Combine
import MapKit
import UIKit
import SystemConfiguration

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    
    func tentative(format: Bool) -> String {
        if format {
            return self.count == 5 ? self : to24(time: self)
        } else {
            return to12(time: self)
        }
    }
}

func to24(time: String) -> String {
    let markers = ["1": "13", "2": "14", "3": "15", "4": "16", "5": "17", "6": "18", "7": "19", "8": "20", "9": "21", "10": "22", "11": "23", "12": "12"]
    
    // hour is 10, 11, 12
    if time.count == 8 {
        let plainTime = time[0..<5]
        let hours = plainTime[0..<2]
        let minutes = plainTime[3..<5]
        if time[6] == "A" {
            if hours == "12" {
                return "00:\(minutes)"
            } else {
                return "\(hours):\(minutes)"
            }
        } else { // PM
            if hours == "12" {
                return "12:\(minutes)"
            } else {
                if let hour = markers[hours] {
                    return "\(hour):\(minutes)"
                }
                return "00:00"
            }
        }
    } else { // time.count == 7
        let plainTime = time[0..<4]
        let hours = plainTime[0]
        let minutes = plainTime[2..<4]
        if time[5] == "A" {
            return "0\(hours):\(minutes)"
        } else { // PM
            if let hour = markers[hours] {
                return "\(hour):\(minutes)"
            }
            return "00:00"
        }
    }
}

func to12(time: String) -> String {
    if time.isEmpty {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let dateString = formatter.string(from: Date())
        return dateString
    }
    
    if time.count >= 7 {
        return time
    }
    
    var hours = Int(time.substring(toIndex: 2)) ?? 0
    var meridien = "AM" // currently am
    
    // if pm
    if hours >= 12 {
        meridien = "PM"
    }
    
    hours %= 12
    
    if hours == 0 {
        hours = 12
    }
    
    return "\(hours):\(time[3..<5]) \(meridien)"
}

func calculateTime(time1: String, time2: String) -> String {
    let hours1 = Int(time1.prefix(2))
    let hours2 = Int(time2.prefix(2))
    let minutes1 = Int(time1.suffix(2))
    let minutes2 = Int(time2.suffix(2))
    
    if let hours1 = hours1, let hours2 = hours2, let minutes1 = minutes1, let minutes2 = minutes2 {
        let factor = hours1 < hours2 ? 24 : 0
        
        var hours = (hours1 + factor) - hours2
        var minutes = minutes1 - minutes2 - 1
        if minutes < 0 {
            minutes = 60 - (-1 * minutes)
            hours -= 1
        }
        
        if minutes < 10 {
            return "\(hours):0\(minutes)"
        } else {
            return "\(hours):\(minutes)"
        }
    }
    
    return "..."
}

// renvoie 1 si time1 > time2, 2 s'ils sont égaux, 3 si time1 < time2, suelment 24h format
func compareTime(time1: String, time2: String) -> Int {
    let hours1 = Int(time1.prefix(2))
    let hours2 = Int(time2.prefix(2))
    
    if let hours1 = hours1, let hours2 = hours2 {
        if hours1 > hours2 {
            return 1
        } else if hours1 == hours2 {
            let minutes1 = Int(time1.suffix(2))
            let minutes2 = Int(time2.suffix(2))
            
            if let minutes1 = minutes1, let minutes2 = minutes2 {
                if minutes1 > minutes2 {
                    return 1
                } else if minutes1 == minutes2 {
                    return 2
                } else {
                    return 3
                }
            }
            
        } else {
            return 3
        }
    }
    return -1
}

// utilisé pour savoir quelle prière qu'on doit faire surligner
func checkCurrentPrayer(currentPrayer: Int, expectedPrayer: String) -> Bool {
    if currentPrayer == 1 {
        return false
    }
    if names[currentPrayer] == expectedPrayer {
        return true
    } else {
        return false
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation? = nil
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        self.location = location
    }
}


public class LocationProvider: NSObject, ObservableObject {
    
    private let lm = CLLocationManager()
    
    public let locationWillChange = PassthroughSubject<CLLocation, Never>()
    @Published public private(set) var location: CLLocation? {
        willSet {
            locationWillChange.send(newValue ?? CLLocation())
        }
    }
    
    public func getPlace(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                completion(nil)
                return
            }
            guard let placemark = placemarks?.first else {
                completion(nil)
                return
            }
            completion(placemark)
        }
    }
    
}

extension CLLocationCoordinate2D {
    func authorized() -> Bool {
        return self.latitude != 9999.8 && self.longitude != 9999.8
    }
}

class NetworkReachability: ObservableObject {
    @Published private(set) var reachable: Bool = false
    private let reachability = SCNetworkReachabilityCreateWithName(nil, "www.designcode.io")

    init() {
        self.reachable = checkConnection()
    }

    private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let connectionRequired = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutIntervention = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!connectionRequired || canConnectWithoutIntervention)
    }

    func checkConnection() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)

        return isNetworkReachable(with: flags)
    }
}
