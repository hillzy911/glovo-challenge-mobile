import UIKit
import UIKit
import GoogleMaps
import GooglePlaces
import HAActionSheet

class HomeViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var placesClient: GMSPlacesClient!
    var currentZoomLevel: Float?
    var countries: [Country] = []
    var cities: [City] = []
    var currentCountry: [City] = []
    var zoomedOut: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showCities))
        DispatchQueue.global(qos: .background).async {
            self.getCountries()
            self.getCities()
            DispatchQueue.main.async {
               self.loadMap()
            }
        }
    }
    
    @objc func showCities(){
        
        var data:[String] = []
        for cities in self.cities{
            data.append(cities.name)
        }
        let view = HAActionSheet(fromView: self.view, sourceData: data)
        view.buttonCornerRadius = 16
        view.show { (canceled, index) in
            if !canceled {
                self.mapView.clear()
                let workingAreas = self.cities.filter({ $0.countryId == self.cities[index!].countryId })
                self.currentCountry = workingAreas
                self.getArea(code: self.cities[index!].code)
            }
        }
    }
    
    //get countries
    func getCountries() {
        APIClient.getCountries{ result in
            switch result {
            case .success(let countries):
                self.countries = countries
            case.failure(let error):
                self.displayErrorAlert(error: error)
            }
        }
    }
    
    //get area
    func getArea(code: String) {
        APIClient.getArea(areaCode: code){ result in
            switch result {
            case .success(let area):
                
                var bounds = GMSCoordinateBounds()
                for workingArea in area.workingAreas {
                    let polygon = GMSPolygon()
                    polygon.path = GMSPath(fromEncodedPath: workingArea)
                    if(area.enabled){
                        //fill out with blue for enabled
                        polygon.fillColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
                        polygon.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
                    } else {
                         //fill out with grey for disabled
                        polygon.fillColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
                        polygon.strokeColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
                    }
                    
                    if(polygon.path?.count() != 0){
                        for index in 1...polygon.path!.count() {
                            bounds = bounds.includingCoordinate(polygon.path!.coordinate(at: index))
                        }
                    }
                    polygon.strokeWidth = 2
                    polygon.map = self.mapView
                }
                
                let update = GMSCameraUpdate.fit(bounds, withPadding: 10)
                self.mapView.animate(with: update)
                
                if let title = area.description {
                    self.title = title
                }
                
                
            case .failure(let error):
                self.displayErrorAlert(error: error)
            }
        }
    }
    
    //get cities
    func getCities() {
        APIClient.getCities{ result in
            switch result {
            case .success(let cities):
                self.cities = cities.sorted { $0.countryId < $1.countryId }
            case .failure(let error):
                self.displayErrorAlert(error: error)
            }
        }
    }
    
    //initialize delegate methods
    func initializeLocationManager() {
        self.mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
     
    }
    
    //load default map
    func loadMap() {
        initializeLocationManager()
        let initialLocation = CLLocationCoordinate2D(latitude: 41.383682, longitude: 2.176591)
        let camera = GMSCameraPosition.camera(withTarget: initialLocation, zoom: 16)
        self.mapView.camera = camera
    }
    
    func drawWorkingAreasByCountry(cities: [City]) {
        for city in cities {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `0.5` to the desired number of seconds.
                for workingArea in city.workingArea {
                    let polygon = GMSPolygon()
                    polygon.path = GMSPath(fromEncodedPath: workingArea)
                    polygon.fillColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
                    polygon.strokeColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
                    polygon.strokeWidth = 2
                    polygon.map = self.mapView
                }
            }
        }
    }
    
    //draw markers using cnter of polygons
    func drawWorkingMarkersByCountry(cities: [City]) {
        for city in cities {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `0.5` to the desired number of seconds.
                for workingArea in city.workingArea {
                    let polygon = GMSPolygon()
                    polygon.path = GMSPath(fromEncodedPath: workingArea)
                    if(polygon.path?.count() != 0) {
                        let position = CLLocationCoordinate2D(latitude: self.getPolygonCenter(polygon: polygon).latitude, longitude: self.getPolygonCenter(polygon: polygon).longitude)
                        let marker = GMSMarker(position: position)
                        let values = ["latitude" : position.latitude, "longitude" : position.longitude] as [String : Any]
                        marker.userData = values
                        marker.title = city.name
                        marker.snippet = city.code
                        
                        marker.map = self.mapView
                    }
                }
            }
        }
    }
    
    //center of each polygon
    func getPolygonCenter(polygon: GMSPolygon) -> CLLocationCoordinate2D {
        var bounds: GMSCoordinateBounds = GMSCoordinateBounds()
        
        for index in 1...polygon.path!.count() {
            bounds = bounds.includingCoordinate(polygon.path!.coordinate(at: index))
        }
    
        let center: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        return  center.middleLocationWith(firstLocation: bounds.northEast, secondLocation: bounds.southWest)
    }
    
    
    func displayErrorAlert(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let geoCoder = CLGeocoder()
        let location = CLLocation(latitude: (locations.first?.coordinate.latitude)! , longitude: (locations.first?.coordinate.longitude)!)
        let gmsLocation = CLLocationCoordinate2D(latitude: (locations.first?.coordinate.latitude)!, longitude: (locations.first?.coordinate.longitude)!)
        self.currentLocation = gmsLocation
        let camera = GMSCameraPosition.camera(withTarget: gmsLocation, zoom: 16)
        self.mapView.animate(to: camera)
        
        
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            // Country
            guard let country = placeMark.addressDictionary!["Country"] as? String else {
                return
            }
            
          
            if self.countries.contains(where: {$0.name == country}) {
                let currentCountry: Country = self.countries.first(where: {$0.name == country})!
                let workingAreas = self.cities.filter({ $0.countryId == currentCountry.code })
                self.currentCountry = workingAreas
                self.drawWorkingAreasByCountry(cities: workingAreas)
            }
        })
        
    }

    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            
            // create the alert
            let alert = UIAlertController(title: "Alert", message: "Turn On Location Services to allow maps to determine your location", preferredStyle: UIAlertController.Style.alert)
            
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "Review Location Settings", style: UIAlertAction.Style.default, handler: {_ in
                if let url = NSURL(string:UIApplication.openSettingsURLString) {
                    UIApplication.shared.openURL(url as URL)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "It is okay, I will use search", style: UIAlertAction.Style.destructive, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)

            // Display the map using the default location.
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error.localizedDescription)
    }
    
}

extension HomeViewController: GMSMapViewDelegate {
    
    // MARK: GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("You tapped at \(coordinate.latitude), \(coordinate.longitude)")
        
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //
        print("Map is idle")
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if (mapView.myLocation != nil) {
            self.mapView.clear()
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: (mapView.myLocation?.coordinate.latitude)! , longitude: (mapView.myLocation?.coordinate.longitude)!)
            let gmsLocation = CLLocationCoordinate2D(latitude: (mapView.myLocation?.coordinate.latitude)!, longitude: (mapView.myLocation?.coordinate.latitude)!)
            self.currentLocation = gmsLocation
            let camera = GMSCameraPosition.camera(withTarget: gmsLocation, zoom: 16)
            self.mapView.animate(to: camera)
            
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
                
                var placeMark: CLPlacemark!
                placeMark = placemarks?[0]
                
                // Country
                guard let country = placeMark.addressDictionary!["Country"] as? String else {
                    return
                }
                
                
                if self.countries.contains(where: {$0.name == country}) {
                    let currentCountry: Country = self.countries.first(where: {$0.name == country})!
                    let workingAreas = self.cities.filter({ $0.countryId == currentCountry.code })
                    self.currentCountry = workingAreas
                    self.drawWorkingAreasByCountry(cities: workingAreas)
                }
            })
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        self.getArea(code: marker.snippet!)
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        if(mapView.camera.zoom <= 12 && !self.zoomedOut){
            mapView.clear()
            if(!self.currentCountry.isEmpty){
                self.drawWorkingMarkersByCountry(cities: self.currentCountry)
            }
            self.zoomedOut = true
        } else if(mapView.camera.zoom > 12 && self.zoomedOut) {
            mapView.clear()
            if(!self.currentCountry.isEmpty){
                self.drawWorkingAreasByCountry(cities: self.currentCountry)
            }
            self.zoomedOut = false
        }
    }
    
}
