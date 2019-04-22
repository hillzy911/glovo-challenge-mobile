import Foundation

struct City: Codable {
    
    public let code: String
    public let name: String
    public let countryId: String
    public let workingArea: [String]
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case countryId = "country_code"
        case workingArea = "working_area"
    }
    
}
