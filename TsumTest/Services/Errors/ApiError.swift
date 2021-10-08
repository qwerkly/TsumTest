//
//  ApiError.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 06.10.2021.
//

import Foundation

struct ApiError: Decodable {
    let error: Error
    
    struct Error: Decodable {
        let code: String
        let message: String
    }
}

extension ApiError: LocalizedError {
    var errorDescription: String? { error.message }
}
