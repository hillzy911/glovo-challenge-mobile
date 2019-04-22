import UIKit
import UIKit
import GoogleMaps
import GooglePlaces

class HomeViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //use user's location or chosen country
        //create a search bar with 0 width and 0 height
   
        
        //set the frame to 0 height because line above sets the height to zero.  CGRectMake(0, 10, 100, searchBar.frame.size.height)
        //initialize Search
        let searchBar: UISearchBar = UISearchBar(frame: .zero)
        self.navigationItem.title = "Your Title"
        searchBar.frame = CGRect(x: 0, y: 0, width: 0, height: searchBar.frame.size.height)
        let topBarHeight = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        searchBar.frame = CGRect(x: 0, y: topBarHeight, width: view.frame.size.width, height: 44)
        searchBar.isTranslucent = true
        view.addSubview(searchBar)
        self.loadMap()
    }
    
    
    func getCountries() {
        
    }
    
    func getArea(code: String) {
        APIClient.getArea(areaCode: code){ result in
            switch result {
            case .success(let area):
                let hydeParkLocation = CLLocationCoordinate2D(latitude: 41.3851, longitude: 2.1734)
                let camera = GMSCameraPosition.camera(withTarget: hydeParkLocation, zoom: 13)
                
                for workingArea in area.workingAreas {
                    let polygon = GMSPolygon()
                    polygon.path = GMSPath(fromEncodedPath: workingArea)
                    polygon.fillColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
                    polygon.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
                    polygon.strokeWidth = 2
                    polygon.map = self.mapView
                }
    
                self.findCenter()
                self.mapView.camera = camera
                
//                for index in 1...path.count() {
//                    bounds = bounds.includingCoordinate(path.coordinateAtIndex(index))
//                }
                
                //mapView.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(bounds))
                //for coordinates in {area.
            case .failure(let error):
                print(print("############stucko: \(error.localizedDescription)"))
            }
        }
    }
    
    func getCities() {
        APIClient.getCities{ result in
            switch result {
            case .success(let cities):
                print("############We are the ones: \(cities[0].name)")
            case .failure(let error):
                print(print("############stucko: \(error.localizedDescription)"))
            }
        }
    }
    
    func initializeLocationManager() {
        self.mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
     
    }
    
    func loadMap() {
        
        let hydeParkLocation = CLLocationCoordinate2D(latitude: 41.3851, longitude: 2.1734)
        let camera = GMSCameraPosition.camera(withTarget: hydeParkLocation, zoom: 16)
        self.mapView.camera = camera
        initializeLocationManager()
        
        getArea(code: "BCN")
        
    }
    
    func findCenter() {
        
    }
    
    func contains(polygon: [CGPoint], test: CGPoint) -> Bool {
        if polygon.count <= 1 {
            return false //or if first point = test -> return true
        }
        
        let p = UIBezierPath()
        let firstPoint = polygon[0] as CGPoint
        
        p.move(to: firstPoint)
        
        for index in 1...polygon.count-1 {
            p.addLine(to: polygon[index] as CGPoint)
        }
        
        p.close()
        
        return p.contains(test)
    }
    
}

extension HomeViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let hydeParkLocation = CLLocationCoordinate2D(latitude: -33.87344, longitude: 151.21135)
//        let camera = GMSCameraPosition.camera(withTarget: hydeParkLocation, zoom: 16)
//        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
//        mapView.animate(to: camera)
//
//        let hydePark = "tpwmEkd|y[QVe@Pk@BsHe@mGc@iNaAKMaBIYIq@qAMo@Eo@@[Fe@DoALu@HUb@c@XUZS^ELGxOhAd@@ZB`@J^BhFRlBN\\BZ@`AFrATAJAR?rAE\\C~BIpD"
//        let archibaldFountain = "tlvmEqq|y[NNCXSJQOB[TI"
//        let reflectionPool = "bewmEwk|y[Dm@zAPEj@{AO"
//
//        let polygon = GMSPolygon()
//        polygon.path = GMSPath(fromEncodedPath: hydePark)
//        //polygon.holes = [GMSPath(fromEncodedPath: archibaldFountain)!, GMSPath(fromEncodedPath: reflectionPool)!]
//        polygon.fillColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
//        polygon.strokeColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
//        polygon.strokeWidth = 2
//        polygon.map = mapView
//        view = mapView
//
//        //listLikelyPlaces()
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
}

extension HomeViewController: GMSMapViewDelegate {
    
    // MARK: GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if(mapView.camera.zoom > mapView.maxZoom/2){
           // mapView.clear()
        }
    }
    
}
