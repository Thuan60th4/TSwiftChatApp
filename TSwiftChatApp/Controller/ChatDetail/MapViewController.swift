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
    
    //MARK: - UI
    let mapView: MKMapView = {
        let map = MKMapView()
        map.showsUserLocation = true
        return map
    }()
    
    //có thể add trực tiếp mapView mà ko cần mapViewContain
    let mapViewContain: UIView = {
        //must have when use NSLayoutConstraint
        let contain = UIView()
        contain.translatesAutoresizingMaskIntoConstraints = false
        return contain
    }()
    
    let goToAppleMapBtn : UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Go to Apple map", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(goToAppleMap), for: .touchUpInside)
        //button.layer.zPosition = 99
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMapView()
        configureNavigationBar()
        
    }
    
    //MARK: - Configure navigation bar
    func configureNavigationBar(){
        title = "Apple Map"
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial) // or dark
        
        //        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        //        navigationController?.navigationBar.compactAppearance = appearance
        
    }
    //MARK: - Configuration mao view
    private func configureMapView(){
        view.addSubview(mapViewContain)
        view.addSubview(goToAppleMapBtn)
        
        applyConstraint()
        
        //Phương thức layoutIfNeeded() sẽ buộc việc layout xảy ra ngay lập tức, và sau đó bạn có thể lấy kích thước của mapViewContain
        view.layoutIfNeeded()
        
        mapView.frame = mapViewContain.frame
        if location != nil{
            mapView.setCenter(location!.coordinate, animated: false)
            mapView.addAnnotation(MapAnnotation(title: locationName, coordinate: location!.coordinate))
        }
        mapViewContain.addSubview(mapView)
    }
    
    
    //MARK: - Add constrait
    func applyConstraint(){
        
        //Buộc phải thêm vào sau khi addSubview để nó tính toán đc các ràng buộc hoặc dùg method layoutSubview() cũg đc vì sau khi addSubview nó sẽ chạy phương thức này
        
        //--mapViewContain
        NSLayoutConstraint.activate([
            //mapViewContain.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapViewContain.topAnchor.constraint(equalTo: view.topAnchor),
            mapViewContain.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapViewContain.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapViewContain.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        //-- apple map button
        NSLayoutConstraint.activate([
            goToAppleMapBtn.bottomAnchor.constraint(equalTo: view.bottomAnchor,constant: -70),
            goToAppleMapBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    
    //MARK: - Action
    @objc func goToAppleMap(){
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location?.coordinate ?? CLLocationCoordinate2D(), addressDictionary: nil))
        mapItem.name = locationName
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
        
    }
    
}
