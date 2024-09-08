//
//  WeatherService.swift
//  
//
//  Created by Sergei Runov on 07.09.2024.
//

import Foundation

public final class WeatherService: WeatherServiceProtocol {
    
    // MARK: - Properties
    
    private let host: String
    private let apiKey: String
    
    // MARK: - Initialization
    
    public init(apiUrl: String, apiKey: String) {
        self.host = apiUrl
        self.apiKey = apiKey
    }
        
    // MARK: - Methods
    
    public func getWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherAPIResponseDTO, ServiceError>) -> Void) {
        
        // TODO: Method to construct URL
        let endpoint = "data/2.5/weather"
        let parameters = "?units=metric&lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        let urlString = host + endpoint + parameters
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.badUrl(url: urlString)))
            return
        }
        
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                guard let error else { return }
                completion(.failure(.serverError(error: error)))
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(.failure(.badResponse))
                return
            }
            
            guard let data else {
                completion(.failure(.returnedDataIsEmpty))
                return
            }
            
            do {
                let dto = try JSONDecoder().decode(WeatherAPIResponseDTO.self, from: data)
                completion(.success(dto))
            } catch {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}
