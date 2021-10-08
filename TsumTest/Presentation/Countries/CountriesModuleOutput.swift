//
//  CountriesModuleOutput.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 07.10.2021.
//

import Foundation
import RxSwift

protocol CountriesModuleOutput: AnyObject {
    var didSelectCountry: Observable<String> { get }
}
