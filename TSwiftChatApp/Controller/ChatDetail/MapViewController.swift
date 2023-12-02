//
//  MapViewController.swift
//  TSwiftChatApp
//
//  Created by Pham Minh Thuan on 02/12/2023.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController {
    
    //MARK: - Vars
    var location : CLLocation?
    var locationName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        title = "Apple Map"
    }
    
    //MARK: - Configuration
    private func configureMapView(){
        let mapView = MKMapView()
        //có thể add trực tiếp mapView mà ko cần mapViewContain
        let mapViewContain = UIView()
        
        //must have when use NSLayoutConstraint
        mapViewContain.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .systemBackground
        view.addSubview(mapViewContain)
        //buộc phải thêm vào sau khi addSubview để nó tính toán đc các ràng buộc
        NSLayoutConstraint.activate([
            mapViewContain.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapViewContain.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapViewContain.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapViewContain.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        //Phương thức layoutIfNeeded() sẽ buộc việc layout xảy ra ngay lập tức, và sau đó bạn có thể lấy kích thước của mapViewContain
        view.layoutIfNeeded()
        
        mapView.frame = mapViewContain.frame
        mapView.showsUserLocation = true
        if location != nil{
            mapView.setCenter(location!.coordinate, animated: false)
            mapView.addAnnotation(MapAnnotation(title: locationName, coordinate: location!.coordinate))
        }
        mapViewContain.addSubview(mapView)
    }
}
