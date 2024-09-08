//
//  ImageService.swift
//
//
//  Created by Sergei Runov on 07.09.2024.
//

import Foundation

public final class ImageService: ImageServiceProtocol {
    
    // MARK: - Properties
    
    private let host: String
    
    // MARK: - Initialization
    
    public init(apiUrl: String) {
        self.host = apiUrl
    }
        
    // MARK: - Methods
    
    // TODO: Find another icons
    public func getData(forImage imageName: String, completion: @escaping (Result<Data, ServiceError>) -> Void) {
        let endpoint = "img/wn/"
        let imageParameter = "\(imageName)@2x.png"
        let urlString = host + endpoint + imageParameter
        
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
            
            completion(.success(data))
        }.resume()
    }
}
