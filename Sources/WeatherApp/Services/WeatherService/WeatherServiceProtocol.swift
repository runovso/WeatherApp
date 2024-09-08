//
//  WeatherServiceProtocol.swift
//
//
//  Created by Sergei Runov on 08.09.2024.
//

public protocol WeatherServiceProtocol {
    func getWeather(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherAPIResponseDTO, ServiceError>) -> Void)
}
