import Foundation
import MapKit

extension CLLocationCoordinate2D {
    // MARK: CLLocationCoordinate2D+MidPoint
    func middleLocationWith(firstLocation: CLLocationCoordinate2D, secondLocation: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        
        let lon1 = firstLocation.longitude * Double.pi / 180
        let lon2 = secondLocation.longitude * Double.pi / 180
        let lat1 = firstLocation.latitude * Double.pi / 180
        let lat2 = secondLocation.latitude * Double.pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        
        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)
        
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat3 * 180 / Double.pi, lon3 * 180 / Double.pi)
        return center
    }
}
