import Alamofire

class APIClient: NSObject {
    

    static func getCountries(completion:@escaping (Result<[Country], Error>)->Void) {
        let jsonDecoder = JSONDecoder()
        AF.request(APIRouter.countries)
            .responseDecodable (decoder: jsonDecoder){ (response: DataResponse<[Country]>) in
                completion(response.result)
        }
    }
    
    static func getCities(completion:@escaping (Result<[City], Error>)->Void) {
        let jsonDecoder = JSONDecoder()
        AF.request(APIRouter.cities)
            .responseDecodable (decoder: jsonDecoder){ (response: DataResponse<[City]>) in
                completion(response.result)
        }
    }
    
    static func getArea(areaCode: String, completion:@escaping (Result<Area, Error>)->Void) {
        let jsonDecoder = JSONDecoder()
        AF.request(APIRouter.area(areaCode))
            .responseDecodable (decoder: jsonDecoder){ (response: DataResponse<Area>) in
                completion(response.result)
        }
    }
}
