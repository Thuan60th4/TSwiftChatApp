//
//  MapAnnotation.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 02/12/2023.
//

import Foundation
import MapKit

class MapAnnotation : NSObject, MKAnnotation {
    var title : String?
    var coordinate: CLLocationCoordinate2D

    init(title: String?, coordinate: CLLocationCoordinate2D){
        self.title = title
        self.coordinate = coordinate
    }
}
