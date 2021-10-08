//
//  CountriesRepository.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 06.10.2021.
//

import Foundation
import Moya
import RxSwift

protocol CountriesRepository {
    func getCountries() -> Single<[Country]>
    func getCountry(by name: String) -> Single<[Country]>
}

final class CountriesRepositoryImpl: CountriesRepository {
    private let provider = MoyaProvider<CountriesTarget>()
    
    func getCountries() -> Single<[Country]> {
        provider.rx
            .request(.getCountries)
            .performMapping(
                valueMapping: Mappings.decodable([Country].self),
                errorMapping: Mappings.decodable(ApiError.self),
                mappingStrategy: MappingStrategies.umpStandard()
            )
            .observe(on: MainScheduler.instance)
    }
    
    func getCountry(by name: String) -> Single<[Country]> {
        provider.rx
            .request(.getCountry(name: name))
            .performMapping(
                valueMapping: Mappings.decodable([Country].self),
                errorMapping: Mappings.decodable(ApiError.self),
                mappingStrategy: MappingStrategies.umpStandard()
            )
            .observe(on: MainScheduler.instance)
    }
}
