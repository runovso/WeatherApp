//
//  LocationManager.swift
//  
//
//  Created by Sergei Runov on 08.09.2024.
//

import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func didUpdateLocation(_ location: CLLocation)
}

final class LocationManager: NSObject, LocationManagerProtocol {
        
    // MARK: - Properties
    
    private let manager = CLLocationManager()
    weak var delegate: LocationManagerDelegate?
    private let delayBetweenRequests: TimeInterval = 5
    private var lastRequestTime: Date?
    private let queue = DispatchQueue(label: "com.example.locationManagerQueue", qos: .utility)
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Methods
    
    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }    
}

// MARK: - CLLocationManagerDelegate methods

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didUpdateLocation(location)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            print("Can't access location")
        }
    }
}
