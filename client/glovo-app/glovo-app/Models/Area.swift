import Foundation

struct Area: Codable {
    
    public let code: String
    public let name: String
    public let description: String?
    public let currency: String
    public let countryId: String
    public let enabled: Bool
    public let timeZone: String
    public let workingAreas: [String]
    public let busy: Bool
    public let languageId: String
    
    enum CodingKeys: String, CodingKey {
        case code
        case name
        case description
        case currency
        case countryId = "country_code"
        case enabled
        case timeZone = "time_zone"
        case workingAreas = "working_area"
        case busy
        case languageId = "language_code"
    }
    
}
