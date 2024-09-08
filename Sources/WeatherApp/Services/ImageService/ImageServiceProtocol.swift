//
//  ImageServiceProtocol.swift
//
//
//  Created by Sergei Runov on 08.09.2024.
//

import Foundation

public protocol ImageServiceProtocol {
    func getData(forImage imageName: String, completion: @escaping (Result<Data, ServiceError>) -> Void)
}
