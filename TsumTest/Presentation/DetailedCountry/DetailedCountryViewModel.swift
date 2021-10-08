//
//  DetailedCountryViewModel.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 06.10.2021.
//

import Foundation
import RxSwift

protocol DetailedCountryViewModel: AnyObject {
    var country: String { get }
    
    var detailedCountry: PublishSubject<Country?> { get }
    var loading: PublishSubject<Bool> { get }
    var hideRepeat: PublishSubject<Bool> { get }
    
    func fetchCountry()
}

final class DetailedCountryViewModelImpl: DetailedCountryViewModel {
    private let repository: CountriesRepository
    
    let country: String
    
    let detailedCountry = PublishSubject<Country?>()
    let loading = PublishSubject<Bool>()
    let hideRepeat = PublishSubject<Bool>()
    
    private let disposeBag = DisposeBag()
    
    init(repository: CountriesRepository, country: String) {
        self.repository = repository
        self.country = country
    }
    
    func fetchCountry() {
        hideRepeat.onNext(true)
        loading.onNext(true)
        
        repository.getCountry(by: country)
            .subscribe(
                onSuccess: { [weak self] country in
                    self?.detailedCountry.onNext(country.first)
                    self?.loading.onNext(false)
                },
                onFailure: { [weak self] error in
                    self?.loading.onNext(false)
                    self?.hideRepeat.onNext(false)
                    error.present()
                }
            )
            .disposed(by: disposeBag)
    }
}
