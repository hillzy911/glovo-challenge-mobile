import Alamofire

enum APIRouter: URLRequestConvertible {
    
    case countries
    case cities
    case area(String)
    
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .countries, .cities, .area:
            return .get
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .countries:
            return "/countries"
        case .cities:
            return "/cities"
        case .area(let code):
            return "/cities/\(code)"
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .countries, .cities, .area:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = try K.ProductionServer.baseURL.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // HTTP Method
        urlRequest.httpMethod = method.rawValue
        
        // Common Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // Parameters
        if let parameters = parameters {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
            }
        }
        
        return urlRequest
    }
}

