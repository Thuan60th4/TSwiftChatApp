//
//  LocationManager.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 07/11/2023.
//

import Foundation
import CoreLocation

class LocationManager : NSObject,CLLocationManagerDelegate{
    static let shared = LocationManager()
    let locationManager = CLLocationManager()
    var locationUpdateHandler: ((CLLocationCoordinate2D) -> Void)?

    override init(){
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestNewLocation(){
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    
    //MARK: - Delegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //.last ở đây là để lấy vị trí cuối cùng chuẩn xác nhất
        if let location = locations.last?.coordinate {
            locationManager.stopUpdatingLocation()
            locationUpdateHandler?(location)
        }
    }

}
