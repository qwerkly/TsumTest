//
//  Country.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 06.10.2021.
//

import Foundation

struct Country: Decodable {
    let name: String
    let capital: String
    let region: String?
    let callingCodes: [String]
}
