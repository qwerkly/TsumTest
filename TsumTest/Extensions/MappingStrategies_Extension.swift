//
//  MappingStrategies_Extension.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 08.10.2021.
//

import Foundation
import Moya

extension MappingStrategies {
    static func umpStandard<Value: Decodable>() -> MappingStrategy<Value, ApiError> {
        return { response, valueMapping, errorMapping in
            do {
                let value = try valueMapping(response)
                
                return value
            } catch let valueMappingError {
                do {
                    let error = try errorMapping(response)
                    throw error
                } catch {
                    if error is ApiError {
                        throw error
                    } else {
                        throw MoyaError.objectMapping(valueMappingError, response)
                    }
                }
            }
        }
    }
}
