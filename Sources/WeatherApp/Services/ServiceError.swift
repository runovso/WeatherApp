//
//  ServiceError.swift
//  
//
//  Created by Sergei Runov on 07.09.2024.
//

public enum ServiceError: Error {
    case badUrl(url: String)
    case serverError(error: Error)
    case badResponse
    case returnedDataIsEmpty
    case decodingError
    
    case weatherService
    case imageService
}
