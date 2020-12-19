//
//  TMDBClient.swift
//  CodeMasters
//
//  Created by Atikur Rahman on 19/12/20.
//

import Foundation

class TMDBClient : NSObject {
    
    func getPopularMovies(completion: @escaping ([Movie]?) -> ()) {
        performGetRequest(method: TMDBClient.Methods.PopularMovie) { (data) in
            var parsedResult: AnyObject!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
                
                guard let results = parsedResult["results"] as? [[String: Any]] else {
                    completion(nil)
                    return
                }
                
                let movies = results.compactMap {Movie(dict: $0)}
                completion(movies)
            } catch {
                print(error)
                completion(nil)
            }
        }
    }
    
    private func performGetRequest(method: String, completionHandler: @escaping (Data) -> ()) {
        guard let url = getURL(for: method) else { return }
        
        let defaultSession = URLSession(configuration: .default)
        let dataTask =
            defaultSession.dataTask(with: url) { data, response, error in
                
                if let error = error {
                    print(error)
                    return
                }
                
                if let data = data,
                   let response = response as? HTTPURLResponse,
                   response.statusCode == 200 {
                    completionHandler(data)
                }
            }
        
        dataTask.resume()
    }
    
    private func getURL(for method: String) -> URL? {
        var components = URLComponents()
        components.scheme = TMDBClient.Constants.ApiScheme
        components.host = TMDBClient.Constants.ApiHost
        components.path = TMDBClient.Constants.ApiPath + method
        components.queryItems = [URLQueryItem]()
        components.queryItems?.append(URLQueryItem(name: "api_key", value: TMDBClient.Constants.ApiKey))
        return components.url
    }
    
    // MARK: - Singleton
    
    static let shared = TMDBClient()
    
    private override init() {}
}