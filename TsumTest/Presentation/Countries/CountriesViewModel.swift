//
//  CountriesViewModel.swift
//  TsumTest
//
//  Created by Бабич Иван Юрьевич on 06.10.2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol CountriesViewModel: AnyObject {
    var loading: PublishSubject<Bool> { get }
    var refresh: PublishRelay<Void> { get }
    var endRefreshing: PublishSubject<Void> { get }
    var countries: PublishSubject<[Country]> { get }
    var selectCountry: AnyObserver<String> { get }
    
    func fetchCountries()
}

final class CountriesViewModelImpl: CountriesViewModel, CountriesModuleOutput {
    let loading = PublishSubject<Bool>()
    let refresh = PublishRelay<Void>()
    let endRefreshing = PublishSubject<Void>()
    let countries = PublishSubject<[Country]>()
    var selectCountry: AnyObserver<String>
    
    var didSelectCountry: Observable<String>
    
    private let disposeBag = DisposeBag()
    
    private let repository: CountriesRepository
    
    init(repository: CountriesRepository) {
        self.repository = repository
        
        let selectCountry = PublishSubject<String>()
        self.selectCountry = selectCountry.asObserver()
        self.didSelectCountry = selectCountry.asObservable()
        
        refresh.subscribe(onNext: { [unowned self] in
            self.fetchCountries()
        })
        .disposed(by: disposeBag)
    }
    
    func fetchCountries() {
        repository.getCountries()
            .subscribe(
                onSuccess: { [unowned self] countries in
                    self.endRefreshing.onNext(())
                    self.countries.onNext(countries)
                    self.loading.onNext(false)
                },
                onFailure: { [unowned self] error in
                    self.endRefreshing.onNext(())
                    self.loading.onNext(false)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        error.present()
                    }
                }
            )
            .disposed(by: disposeBag)
    }
}
