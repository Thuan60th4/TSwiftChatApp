//
//  LocationMessage.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 07/11/2023.
//

import Foundation
import CoreLocation
import MessageKit

class LocationMessage : NSObject,LocationItem {
    var location: CLLocation
    var size: CGSize
    
    init(location: CLLocation){
        self.location = location
        size = CGSize(width: 240, height: 240)
    }
}
