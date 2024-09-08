//
//  WeatherAPIResponseDTO.swift
//  
//
//  Created by Sergei Runov on 07.09.2024.
//

public struct WeatherAPIResponseDTO: Decodable {
    let weather: [Weather]
    let data: WeatherData
    let place: String
    
    enum CodingKeys: String, CodingKey {
        case weather
        case data = "main"
        case place = "name"
    }
}
