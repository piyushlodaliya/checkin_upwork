import Foundation
import CoreLocation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var isAuthorized = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        if let savedLat = UserDefaults.standard.object(forKey: "lastLatitude") as? Double,
           let savedLon = UserDefaults.standard.object(forKey: "lastLongitude") as? Double {
            location = CLLocationCoordinate2D(latitude: savedLat, longitude: savedLon)
        }
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func startTracking() {
        manager.startUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            isAuthorized = true
            startTracking()
        case .denied, .restricted:
            isAuthorized = false
        case .notDetermined:
            requestPermission()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        
        location = latest.coordinate
        UserDefaults.standard.set(latest.coordinate.latitude, forKey: "lastLatitude")
        UserDefaults.standard.set(latest.coordinate.longitude, forKey: "lastLongitude")
    }
}