//
//  CountriesTarget.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 06.10.2021.
//

import Foundation
import Moya

enum CountriesTarget {
    case getCountries
    case getCountry(name: String)
}

// MARK: - ApiTarget
extension CountriesTarget: TargetType {
    private var apiKey: String { "bae543ecbcbde3756fed353f2401c663" }
    
    var baseURL: URL {
        URL(string: "http://api.countrylayer.com/v2")!
    }
    
    var path: String {
        switch self {
        case .getCountries:
            return "/all"
        case .getCountry(let name):
            return "/name/\(name)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCountries, .getCountry:
            return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getCountries:
            return .requestParameters(parameters: ["access_key": apiKey], encoding: URLEncoding.queryString)
        case .getCountry:
            return .requestParameters(
                parameters: [
                    "access_key": apiKey
                ],
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String: String]? {
        nil
    }
}
